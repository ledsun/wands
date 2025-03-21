# frozen_string_literal: true

require "test_helper"
require "async"

class TestBinaryTransmissionWands < Minitest::Test
  def dump(str)
    [str.size].pack("N") + str
  end

  def load(socket)
    size = socket.read(4).unpack1("N")
    socket.read(size)
  end

  def test_length_prefixed_protocol
    server = Wands::WebSocketServer.open("localhost", 0)
    port = server.addr[1]

    Async do |task|
      task.async do
        socket = server.accept

        assert_instance_of Wands::WebSocket, socket
        assert_equal "Hello, World!", load(socket)
        assert_equal "Goodbye, World!", load(socket)

        socket.close
        server.close
      end

      task.async do
        socket = Wands::WebSocket.open("localhost", port)

        assert_instance_of Wands::WebSocket, socket
        socket.write(dump("Hello, World!") + dump("Goodbye, World!"))

        socket.close
      end
    end
  end
end
