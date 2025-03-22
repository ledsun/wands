# frozen_string_literal: true

require "test-unit"
require "js"
require "wands/java_script/queue"

module Wands
  module JavaScript
    # Test Wands::JavaScirpt::Queue
    class TestQueue < Test::Unit::TestCase
      def test_push_and_pop
        queue = Queue.new
        queue.push("Hello World!")
        message = queue.pop

        assert_true message.is_a?(JS::Object)
        assert_equal "Hello World!", message.to_s
      end

      def test_wait_once
        start = Time.now
        Queue.wait_once do |queue|
          JS.global.setTimeout(-> { queue.push(nil) }, 100)
        end
        assert_in_delta 0.1, Time.now - start, 0.05
      end

      def test_push_no_js_like_object
        queue = Queue.new
        assert_raise(TypeError) { queue.push(Object.new) }
      end
    end
  end
end
