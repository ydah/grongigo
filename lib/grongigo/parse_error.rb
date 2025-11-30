# frozen_string_literal: true

module Grongigo
  # Parse error
  class ParseError < StandardError
    attr_reader :token

    def initialize(message, token = nil)
      super(message)
      @token = token
    end
  end
end
