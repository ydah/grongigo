# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Binary expression
    class BinaryExpr < Node
      attr_reader :left, :operator, :right

      def initialize(left, operator, right, line = 0, column = 0)
        super(line, column)
        @left = left
        @operator = operator
        @right = right
      end
    end
  end
end
