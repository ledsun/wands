require "js"
require "wands/web_socket"

socket = Wands::WebSocket.open("localhost", 23456)

p 'open'
socket.puts('Hello World!')

p "receive  #{socket.gets}"
