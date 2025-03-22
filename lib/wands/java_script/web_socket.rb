# frozen_string_literal: true

require "uri"
require_relative "queue"

module Wands
  module JavaScript
    # WebSocket class for when JavaScript is available in the browser.
    # All methods are synchronous and blocking, compatible with the Socket class.
    module WebSocket
      def self.prepended(base) = base.singleton_class.prepend(ClassMethods)

      # The class methods module
      module ClassMethods
        def open(host, port)
          uri = URI::HTTP.build(host:, port:)
          ws = JS.global[:WebSocket].new(uri.to_s)

          instance = new(ws)
          ws.addEventListener("message") do |event|
            instance << event
          end

          Queue.wait_once do |queue|
            ws.addEventListener("open") { queue.push(nil) }
          end

          instance
        end
      end

      def initialize(web_socket)
        @ws = web_socket
        @buffer = Queue.new
      end

      def gets = @buffer.pop

      def puts(str)
        raise "socket is closed" unless @ws[:readyState] == 1

        @ws.send(str)
      end

      # Add an text flame into the buffer
      def <<(event) = @buffer << event[:data]
    end
  end
end
