# frozen_string_literal: true

require "test_helper"
require "async"

class TestWands < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Wands::VERSION
  end

  def test_open_connection
    Async do |task|
      task.async do
        server = Wands::WebSocketServer.open("localhost", 23_456)
        socket = server.accept
        assert_instance_of Wands::WebSocket, socket
        socket.close
      end

      task.async do
        socket = Wands::WebSocket.open("localhost", 23_456)
        assert_instance_of Wands::WebSocket, socket
        socket.close
      end
    end
  end
end
