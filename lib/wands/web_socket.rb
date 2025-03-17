# frozen_string_literal: true

require "socket" unless RUBY_PLATFORM == "wasm32-wasi"
require "forwardable"
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
      @binary_message = "".b
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

    def puts(message)
      frame = Protocol::WebSocket::TextFrame.new(true, message)
      frame.write(@socket)
    end

    def read(length)
      @binary_message = read_next_binary_frame if @binary_message.size.zero?

      raise "not enough data." if @binary_message.size < length

      data = @binary_message.byteslice(0, length)
      @binary_message = @binary_message.byteslice(length, @binary_message.size - length)
      data
    end

    def write(message)
      frame = Protocol::WebSocket::BinaryFrame.new(true, message)
      frame.write(@socket)
    end

    private

    def read_next_binary_frame
      framer = Protocol::WebSocket::Framer.new(@socket)
      frame = framer.read_frame

      case frame
      when Protocol::WebSocket::BinaryFrame
        frame.unpack
      when Protocol::WebSocket::CloseFrame
        Protocol::WebSocket::Message.new
      else
        raise "frame is not a binary"
      end
    end
  end
end
