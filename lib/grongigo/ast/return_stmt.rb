# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # return statement
    class ReturnStmt < Node
      attr_reader :value

      def initialize(value = nil, line = 0, column = 0)
        super(line, column)
        @value = value
      end
    end
  end
end
