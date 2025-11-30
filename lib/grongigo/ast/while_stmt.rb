# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # while statement
    class WhileStmt < Node
      attr_reader :condition, :body

      def initialize(condition, body, line = 0, column = 0)
        super(line, column)
        @condition = condition
        @body = body
      end
    end
  end
end
