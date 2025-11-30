# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # case clause
    class CaseClause < Node
      attr_reader :value, :statements

      def initialize(value, statements, line = 0, column = 0)
        super(line, column)
        @value = value
        @statements = statements
      end
    end
  end
end
