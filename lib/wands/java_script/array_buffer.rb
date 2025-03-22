# frozen_string_literal: true

require "js"

module Wands
  module JavaScript
    # A wrapper around JavaScript ArrayBuffer
    class ArrayBuffer
      def initialize(js_array_buffer = nil)
        @data = "".b

        return unless js_array_buffer
        raise ArgumentError, "Expected a JavaScript ArrayBuffer" unless JS.is_a?(js_array_buffer,
                                                                                 JS.global[:ArrayBuffer])

        uint8_array = JS.global[:Uint8Array].new(js_array_buffer)

        (0...js_array_buffer[:byteLength].to_i).each do |index|
          @data << uint8_array[index].to_i.chr
        end
      end

      def write(binary_string)
        raise ArgumentError, "must be ASCII-8BIT encoded" unless binary_string.encoding == Encoding::ASCII_8BIT

        @data << binary_string
      end

      def to_js_array_buffer
        uint8_array = JS.global[:Uint8Array].new(@data.bytesize)

        @data.bytes.each_with_index do |byte, index|
          uint8_array[index] = byte
        end

        uint8_array[:buffer]
      end

      def read
        @data.dup
      end

      def size
        @data.bytesize
      end
    end
  end
end
