# frozen_string_literal: true

module Wands
  # This is a class that parses the response from the server and stores the headers in a hash.
  # The parse and header methods in this class are modeled on WEBrick::HTTPRequest.
  #
  # The expected HTTP response string is:
  #
  # HTTP/1.1 101 Switching Protocols
  # Upgrade: websocket
  # Connection: Upgrade
  # Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
  # Sec-WebSocket-Protocol: chat
  # Sec-WebSocket-Version: 13
  #

  # Example usage:
  #
  # response = HTTPResponse.new
  # response.parse(socket)
  # response.header["upgrade"] # => ["websocket"]
  # response.header["connection"] # => ["Upgrade"]
  # response.header["sec-websocket-accept"] # => ["s3pPLMBiTxaQ9kYGzzhZRbK+xOo="]
  #
  class HTTPResponse
    attr_reader :header

    def parse(stream)
      @response = read_from stream
      @header = headers_of @response
    end

    def to_s
      @response
    end

    private

    def read_from(stream)
      response_string = ""
      while (line = stream.gets) != "\r\n"
        response_string += line
      end

      response_string
    end

    # Parse the headers from the HTTP response string.
    def headers_of(response_string)
      # Split the response string into headers and body.
      headers, _body = response_string.split("\r\n\r\n", 2)

      # Split the headers into lines.
      headers_lines = headers.split("\r\n")

      # The first line is the status line.
      # We don't need it, so we remove it from the headers.
      _status_line = headers_lines.shift

      # Parse the headers into a hash.
      headers_lines.to_h do |line|
        # Split the line into header name and value.
        header_name, value = line.split(": ", 2)
        [header_name.downcase, [value.strip]]
      end
    end
  end
end
