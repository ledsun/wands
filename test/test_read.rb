# frozen_string_literal: true

require "test_helper"
require "async"

class TestWands < Minitest::Test
  def test_send_and_receive_message
    Async do |task|
      task.async do
        server = Wands::WebSocketServer.open("localhost", 23_456)
        socket = server.accept

        assert_instance_of Wands::WebSocket, socket
        assert_equal "Hello, ", socket.read(7)
        assert_equal "World!", socket.read(6)

        socket.close
        server.close
      end

      task.async do
        socket = Wands::WebSocket.open("localhost", 23_456)

        assert_instance_of Wands::WebSocket, socket
        socket.write("Hello, World!")

        socket.close
      end
    end
  end
end
