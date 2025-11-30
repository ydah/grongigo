# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # if statement
    class IfStmt < Node
      attr_reader :condition, :then_branch, :else_branch

      def initialize(condition, then_branch, else_branch = nil, line = 0, column = 0)
        super(line, column)
        @condition = condition
        @then_branch = then_branch
        @else_branch = else_branch
      end
    end
  end
end
