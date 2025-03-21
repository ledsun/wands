# frozen_string_literal: true

require "js"
require "wands/web_socket"

socket = Wands::WebSocket.open("localhost", 23_456)

socket.puts("Hello World!")

p "receive  #{socket.gets}"

socket.puts("Goodbye World!")

p "receive  #{socket.gets}"
