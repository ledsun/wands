# frozen_string_literal: true

require "test-unit"
require "js"
require "wands/web_socket"

module Wands
  # Test Wands::WebSocket
  class TestWebSocket < Test::Unit::TestCase
    def test_open_failure
      assert_raise(JavaScript::JSError) { WebSocket.open("localhost", 23_456) }
    end

    def test_open_success
      web_socket = WebSocket.open("localhost", 8080)
      assert_instance_of(WebSocket, web_socket)
      web_socket.close
    end

    def test_puts_and_gets
      web_socket = WebSocket.open("localhost", 8080)
      web_socket.puts("Hello World!")

      received = web_socket.gets
      assert_instance_of(String, received)
      assert_equal("Hello World!", received)

      web_socket.close
    end

    def test_write_and_read
      web_socket = WebSocket.open("localhost", 8080)
      web_socket.write("Hello World!".b)

      received = web_socket.read(12)
      assert_instance_of(String, received)
      assert_equal("Hello World!", received)

      web_socket.close
    end
  end
end
