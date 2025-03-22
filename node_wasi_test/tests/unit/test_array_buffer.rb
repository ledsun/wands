# frozen_string_literal: true

require "test-unit"
require "js"
require "wands/js/array_buffer"

module Wands
  module JS
    # Test Wands::JS::ArrayBuffer
    class TestArrayBuffer < Test::Unit::TestCase
      # rubocop:disable Naming/MethodName
      def test_to_js_array_buffer_returns_ArrayBuffer
        @buffer = ArrayBuffer.new
        @buffer.write("\x10\x20\x30".b)
        js_buffer = @buffer.to_js_array_buffer

        assert_true(::JS.is_a?(js_buffer, ::JS.global[:ArrayBuffer]))
        assert_equal(3, ::JS.global[:Uint8Array].new(js_buffer)[:length])
      end
      # rubocop:enable Naming/MethodName

      def test_initialize_with_js_array_buffer
        original = "\xaa\xbb\xcc".b
        @buffer = ArrayBuffer.new
        @buffer.write(original)
        js_buf = @buffer.to_js_array_buffer

        new_buffer = ArrayBuffer.new(js_buf)
        assert_equal(original, new_buffer.read)
      end
    end
  end
end
