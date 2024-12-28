# frozen_string_literal: true

module Wands
  # This exception is raised when the response from the server is not as expected.
  class ResponseException < StandardError
    attr_reader :response

    def initialize(message, response)
      super(message)
      @response = response
    end

    def to_s
      "#{super} from '#{response}'"
    end
  end
end
