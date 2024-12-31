# frozen_string_literal: true

require "socket"
require "protocol/websocket/headers"
require "webrick/httprequest"
require "webrick/httpresponse"
require "webrick/config"
require_relative "web_socket"

module Wands
  # The WebSocketServer class is responsible for accepting WebSocket connections.
  # This class has the same interface as TCPServer.
  #
  # Example usage:
  #
  # server = WebSocketServer.new('localhost', 2345)
  # loop do
  #  begin
  #   socket = server.accept
  #   next unless socket
  #   puts "Accepted connection from #{socket.remote_address.ip_address} #{socket.remote_address.ip_port}"
  #
  #   received_message = socket.gets
  #   puts "Received: #{received_message}"
  #
  #   socket.write received_message
  #   socket.close
  #  rescue WEBrick::HTTPStatus::EOFError => e
  #   STDERR.puts e.message
  #  rescue Errno::ECONNRESET => e
  #   STDERR.puts "#{e.message} #{socket.remote_address.ip_address} #{socket.remote_address.ip_port}"
  #  rescue EOFError => e
  #   STDERR.puts "#{e.message} #{socket.remote_address.ip_address} #{socket.remote_address.ip_port}"
  #  end
  # end
  #
  class WebSocketServer
    include Protocol::WebSocket::Headers

    def self.open(hostname, port)
      new(hostname, port)
    end

    def initialize(hostname, port)
      @tcp_server = TCPServer.new hostname, port
    end

    def accept
      socket = @tcp_server.accept

      request = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
      headers = read_headers_from request, socket
      unless headers["upgrade"].include? PROTOCOL
        socket.close
        raise "Not a websocket request"
      end

      response = response_to headers
      response.send_response socket

      WebSocket.new socket
    rescue WEBrick::HTTPStatus::BadRequest => e
      warn "WEBRick error message: #{e.full_message}"
      warn "HTTP request string: #{request}" if request
      if socket
        socket.write "HTTP/1.1 400 Bad Request\r\n\r\n"
        socket.close
      end
    end

    private

    def read_headers_from(request, socket)
      request.parse(socket)
      request.header
    end

    def response_to(headers)
      response_key = calculate_accept_nonce_from headers
      response = WEBrick::HTTPResponse.new(WEBrick::Config::HTTP)
      response.status = 101
      response.upgrade! PROTOCOL
      response[SEC_WEBSOCKET_ACCEPT] = response_key

      response
    end

    def calculate_accept_nonce_from(headers)
      key = headers[SEC_WEBSOCKET_KEY].first
      Nounce.accept_digest(key)
    end
  end
end
