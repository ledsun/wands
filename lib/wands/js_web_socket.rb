# frozen_string_literal: true

require "uri"

module Wands
  module JSWebSocket
    def self.prepended(base)
      base.singleton_class.prepend(ClassMethods)
    end

    module ClassMethods
      def open(host, port)
        uri = URI::HTTP.build(host:, port:)
        ws = JS.global[:WebSocket].new(uri.to_s)
        instance = new(ws)

        opening_waiter = JS.global[:Promise].new do |resolve|
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

    def initialize(ws)
      @ws = ws
      @is_open = ws[:readyState] == 1
      @received_messages = []
    end

    def puts(str)
      raise "socket is closed" unless @ws[:readyState] == 1

      @ws.send(str)
    end

    def gets
      # message is received
      # return message
      return @received_messages.shift unless @received_messages.empty?

      # message is not received
      # set promise and wait
      resolve2 = nil
      promise = JS.global[:Promise].new do |resolve|
        resolve2 = resolve
      end
      @message_waiter = resolve2
      promise.await
    end

    def <<(event)
      message = event[:data].to_s

      if @message_waiter
        @message_waiter.apply message
        @message_waiter = nil
      else
        @received_messages << message
      end
    end
  end
end