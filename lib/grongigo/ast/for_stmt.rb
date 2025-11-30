# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # for statement
    class ForStmt < Node
      attr_reader :init, :condition, :update, :body

      def initialize(init, condition, update, body, line = 0, column = 0)
        super(line, column)
        @init = init
        @condition = condition
        @update = update
        @body = body
      end
    end
  end
end
