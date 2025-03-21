# frozen_string_literal: true

require "test_helper"
require "async"

class TestWands < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Wands::VERSION
  end

  def test_send_and_receive_message
    port = 23_457

    Async do |task|
      task.async do
        server = Wands::WebSocketServer.open("localhost", port)
        socket = server.accept

        assert_instance_of Wands::WebSocket, socket
        assert_equal "Hello, World!", socket.gets

        socket.puts("Goodbye, World!")
        socket.close
        server.close
      end

      task.async do
        socket = Wands::WebSocket.open("localhost", port)

        assert_instance_of Wands::WebSocket, socket
        socket.puts("Hello, World!")

        assert_equal "Goodbye, World!", socket.gets
        socket.close
      end
    end
  end
end
