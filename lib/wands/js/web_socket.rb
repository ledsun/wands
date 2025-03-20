# frozen_string_literal: true

require "uri"
require_relative 'queue'

module Wands
  module JS
    # WebSocket class for when JavaScript is available in the browser.
    module WebSocket
      def self.prepended(base)
        base.singleton_class.prepend(ClassMethods)
      end

      # The class methods module
      module ClassMethods
        def open(host, port)
          uri = URI::HTTP.build(host:, port:)
          ws = ::JS.global[:WebSocket].new(uri.to_s)
          instance = new(ws)

          opening_waiter = ::JS.global[:Promise].new do |resolve|
            ws.addEventListener("open") do
              resolve.apply
            end
          end

          ws.addEventListener("message") do |event|
            instance << event
          end

          opening_waiter.await

          instance
        end
      end

      def initialize(web_socket)
        @ws = web_socket
        @received_messages = []
        @queue = Queue.new
      end

      def puts(str)
        raise "socket is closed" unless @ws[:readyState] == 1

        @ws.send(str)
      end

      def gets
        @queue.pop
      end

      def <<(event)
        message = event[:data].to_s

        @queue.push(message)
      end
    end
  end
end
