# frozen_string_literal: true

require "uri"
require_relative "queue"
require_relative "js_error"

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
          ws.addEventListener("message") { instance << it }
          wait_until_ready ws
          instance
        end

        private

        def wait_until_ready(js_ws)
          return if js_ws[:readyState] == 1

          js_event = Queue.wait_once do |queue|
            js_ws.addEventListener("open") { queue.push it }
            js_ws.addEventListener("error") { queue.push it }
          end

          return unless js_event[:type].to_s == "error"

          raise JSError.new js_event, "WebSocket connection to #{js_ws[:url]} failed: "
        end
      end

      def initialize(web_socket)
        @socket = web_socket
        @buffer = Queue.new
      end

      def gets = @buffer.pop.to_s

      def puts(str)
        raise "socket is closed" unless @socket[:readyState] == 1

        @socket.send(str)
      end

      # Add an text flame into the buffer
      def <<(event) = @buffer << event[:data]
    end
  end
end
