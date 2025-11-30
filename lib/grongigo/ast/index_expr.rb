# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Array access
    class IndexExpr < Node
      attr_reader :array, :index

      def initialize(array, index, line = 0, column = 0)
        super(line, column)
        @array = array
        @index = index
      end
    end
  end
end
