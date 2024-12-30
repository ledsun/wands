# frozen_string_literal: true

require "erb"
require "protocol/websocket/headers"
require_relative "response_exception"

module Wands
  # The request is used to upgrade the HTTP connection to a WebSocket connection.
  class UpgradeRequest
    include ::Protocol::WebSocket::Headers

    TEMPLATE = <<~REQUEST
      GET / HTTP/1.1
      Host: localhost:2345
      Connection: Upgrade
      Upgrade: websocket
      Sec-WebSocket-Version: 13
      Sec-WebSocket-Key: <%= @key %>

    REQUEST

    ERB = ERB.new(TEMPLATE).freeze

    def initialize
      @key = Nounce.generate_key
    end

    def to_s
      ERB.result(binding).gsub(/\r?\n/, "\r\n")
    end

    def verify(response)
      accept_digest = response.header[SEC_WEBSOCKET_ACCEPT].first
      accept_digest == Nounce.accept_digest(@key) || raise(ResponseException.new("Invalid accept digest", response))
    end
  end
end
