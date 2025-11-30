# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Assignment expression
    class AssignExpr < Node
      attr_reader :target, :value

      def initialize(target, value, line = 0, column = 0)
        super(line, column)
        @target = target
        @value = value
      end
    end
  end
end
