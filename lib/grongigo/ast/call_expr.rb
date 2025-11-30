# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Function call
    class CallExpr < Node
      attr_reader :callee, :arguments

      def initialize(callee, arguments, line = 0, column = 0)
        super(line, column)
        @callee = callee
        @arguments = arguments
      end
    end
  end
end
