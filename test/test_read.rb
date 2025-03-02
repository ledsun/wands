# frozen_string_literal: true

require "test_helper"
require "async"

class TestWands < Minitest::Test
  def dump(str)
    [str.size].pack("N") + str
  end

  def load(socket)
    size = socket.read(4).unpack1("N")
    socket.read(size)
  end

  def test_length_prefixed_protocol
    Async do |task|
      task.async do
        server = Wands::WebSocketServer.open("localhost", 23_457)
        socket = server.accept

        assert_instance_of Wands::WebSocket, socket
        assert_equal "Hello, World!", load(socket)
        assert_equal "Goodbye, World!", load(socket)

        socket.close
        server.close
      end

      task.async do
        socket = Wands::WebSocket.open("localhost", 23_457)

        assert_instance_of Wands::WebSocket, socket
        socket.write(dump("Hello, World!") + dump("Goodbye, World!"))

        socket.close
      end
    end
  end
end
