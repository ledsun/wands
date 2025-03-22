# frozen_string_literal: true

module Wands
  module JavaScript
    # Asynchronous event queuing mechanism utilizing JavaScript's Promise;
    # since it uses JavaScript's API, only objects that can be converted to
    # JavaScript objects can pass through this queue.
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

      # Only objects that can be converted to JavaScript object can be pushed.
      def push(message)
        js_object = JS.try_convert(message)
        raise TypeError, "#{message.class} is not a JS::Object like object" unless js_object

        if @waiter
          @waiter.apply message
          @waiter = nil
        else
          @buffer << js_object
        end
      end
      alias << push

      # The popped object is a JavaScript object.
      # For example, when you push Ruby's false,
      # the pop method will return JS::True.
      def pop
        # message is received
        # return message
        return @buffer.shift unless @buffer.empty?

        # message is not received
        # set promise and wait
        resolve = nil
        promise = JS.global[:Promise].new { resolve = it }
        @waiter = resolve
        promise.await
      end
    end
  end
end
