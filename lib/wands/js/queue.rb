module Wands
  module JS
    class Queue
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