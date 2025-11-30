# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # break statement
    class BreakStmt < Node
      def initialize(line = 0, column = 0)
        super(line, column)
      end
    end
  end
end
