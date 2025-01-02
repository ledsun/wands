#!/usr/bin/env ruby
# frozen_string_literal: true

require "wands"

server = Wands::WebSocketServer.open("localhost", 23_456)
sockets = [server]

loop do
  ready_sockets = IO.select(sockets)
  next unless ready_sockets # select is timeout

  ready_sockets.first.each do |socket|
    if socket == server
      client = server.accept
      sockets << client
      puts "Accepted connection from #{client.remote_address.ip_address} #{client.remote_address.ip_port}"
    else
      if socket.eof?
        puts "Closing connection from #{socket.remote_address.ip_address} #{socket.remote_address.ip_port}"
        socket.close
        sockets.delete(socket)
        next
      else
        message = socket.gets
        if message
          puts "Received: #{message}"
          socket.write(message)
        else
          puts "Closing connection from #{socket.remote_address.ip_address} #{socket.remote_address.ip_port}"
          socket.close
          sockets.delete(socket)
        end
      end
    end
  end

rescue Interrupt
  puts "\nShutting down..."
  break
end