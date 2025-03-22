# frozen_string_literal: true

require "test-unit"
require "js"
require "wands/js/queue"

module Wands
  class TestQueue < Test::Unit::TestCase
    def test_push_and_pop
      queue = Wands::JS::Queue.new
      queue.push("Hello World!")
      assert_equal "Hello World!", queue.pop
    end

    def test_wait_once
      start = Time.now
      Wands::JS::Queue.wait_once do |queue|
        JS.global.setTimeout(-> { queue.push("Hello World!") }, 100)
      end
      assert_in_delta 0.1, Time.now - start, 0.05
    end
  end
end
