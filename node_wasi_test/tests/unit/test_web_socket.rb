# frozen_string_literal: true

require "test-unit"
require "js"
require "wands/web_socket"

module Wands
  # Test Wands::WebSocket
  class TestWebSocket < Test::Unit::TestCase
    def test_open_failure
      assert_raise(JavaScript::JSError) do
        WebSocket.open("localhost", 23_456)
      end
    end
  end
end
