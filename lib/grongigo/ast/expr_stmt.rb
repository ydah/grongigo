# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Expression statement
    class ExprStmt < Node
      attr_reader :expression

      def initialize(expression, line = 0, column = 0)
        super(line, column)
        @expression = expression
      end
    end
  end
end
