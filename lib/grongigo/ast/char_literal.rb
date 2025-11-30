# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Character literal
    class CharLiteral < Node
      attr_reader :value

      def initialize(value, line = 0, column = 0)
        super(line, column)
        @value = value
      end
    end
  end
end
