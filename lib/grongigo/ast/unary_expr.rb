# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Unary expression
    class UnaryExpr < Node
      attr_reader :operator, :operand, :prefix

      def initialize(operator, operand, prefix = true, line = 0, column = 0)
        super(line, column)
        @operator = operator
        @operand = operand
        @prefix = prefix
      end
    end
  end
end
