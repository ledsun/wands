# frozen_string_literal: true

require "socket"
require "forwardable"
require "protocol/websocket/headers"
require "protocol/websocket/framer"
require "protocol/websocket/text_frame"
require_relative "upgrade_request"
require_relative "http_response"
require_relative "response_exception"

module Wands
  # This is a class that represents WebSocket, which has the same interface as TCPSocket.
  #
  # The WebSocket class is responsible for reading and writing messages to the server.
  #
  # Example usage:
  #
  # web_socket = WebSocket.open('localhost', 2345)
  # web_socket.write("Hello World!")
  #
  # puts web_socket.gets
  #
  # web_socket.close
  #
  class WebSocket
    include Protocol::WebSocket::Headers
    extend Forwardable

    def_delegators :@socket, :addr, :remote_address, :close, :to_io, :eof?

    def self.open(host, port)
      socket = TCPSocket.new(host, port)
      request = UpgradeRequest.new(host, port)
      socket.write(request.to_s)
      socket.flush

      response = HTTPResponse.new
      response.parse(socket)
      raise ResponseException.new("Bad Status", response) unless response.status == "101"

      request.verify response

      new(socket)
    end

    def initialize(socket)
      @socket = socket
      @buffer = ""
    end

    def gets
      framer = Protocol::WebSocket::Framer.new(@socket)
      frame = framer.read_frame

      case frame
      when Protocol::WebSocket::TextFrame
        frame.unpack
      when Protocol::WebSocket::CloseFrame
        nil
      else
        raise "frame is not a text"
      end
    end

    def read(length)
      @buffer = gets if @buffer.empty?
      @buffer.slice!(0, length)
    end

    def write(message)
      frame = Protocol::WebSocket::TextFrame.new(true, message)
      frame.write(@socket)
    end
  end
end
