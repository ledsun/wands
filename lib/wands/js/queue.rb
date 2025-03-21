# frozen_string_literal: true

module Wands
  module JS
    # A blocking queue that can be used for waiting for asynchronous events.
    class Queue
      def self.wait_once
        queue = new
        yield queue
        queue.pop
      end

      def initialize
        @waiter = nil
        @buffer = []
      end

      def push(message)
        if @waiter
          @waiter.apply message
          @waiter = nil
        else
          @buffer << message
        end
      end
      alias << push

      def pop
        # message is received
        # return message
        return @buffer.shift unless @buffer.empty?

        # message is not received
        # set promise and wait
        resolve = nil
        promise = ::JS.global[:Promise].new { resolve = it }
        @waiter = resolve
        promise.await
      end
    end
  end
end
