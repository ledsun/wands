# frozen_string_literal: true

require "test_helper"

class TestWands < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Wands::VERSION
  end

  def test_open_connection
    server = Wands::WebSocketServer.open("localhost", 23456)
    t = Thread.start { server.accept }

    socket = Wands::WebSocket.open("localhost", 23456)

    assert_instance_of Wands::WebSocket, socket

    t.join
  end
end
