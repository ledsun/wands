# frozen_string_literal: true

module Wands
  module JavaScript
    # Represents a JavaScript error event, inheriting from Ruby's Error class.
    class JSError < StandardError
      attr_reader :stack

      def initialize(js_error_event, message = nil)
        super("#{message}#{dig_js_values(js_error_event, :message)}")
        @stack = dig_js_values(js_error_event, :error, :stack)
      end

      private

      # Recursively digs into a nested object using the provided keys, returning nil if any key is not found
      # or if the value is `JS::Undefined`.
      def dig_js_values(object, *keys)
        keys.reduce(object) do |value, key|
          return nil if value.nil?

          next_value = value[key]
          next_value == JS::Undefined ? nil : next_value
        end
      end
    end
  end
end
