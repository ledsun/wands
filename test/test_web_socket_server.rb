# frozen_string_literal: true

require "test_helper"

class TestWebSocketServer < Minitest::Test
  def test_open_with_port_zero
    server = Wands::WebSocketServer.open("localhost", 0)
    addr = server.addr
    port = addr[1]

    refute_equal 0, port
  ensure
    server&.close
  end

  def test_close
    server = Wands::WebSocketServer.open("localhost", 23_456)
    server.close

    assert_nil server.instance_variable_get(:@socket)
  end
end
