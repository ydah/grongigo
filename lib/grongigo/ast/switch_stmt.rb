# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # switch statement
    class SwitchStmt < Node
      attr_reader :expression, :cases, :default_case

      def initialize(expression, cases, default_case = nil, line = 0, column = 0)
        super(line, column)
        @expression = expression
        @cases = cases
        @default_case = default_case
      end
    end
  end
end
