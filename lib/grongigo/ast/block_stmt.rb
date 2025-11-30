# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Block文
    class BlockStmt < Node
      attr_reader :statements

      def initialize(statements, line = 0, column = 0)
        super(line, column)
        @statements = statements
      end
    end
  end
end
