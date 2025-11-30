# frozen_string_literal: true

module Grongigo
  module AST
    # AST Node base class
    class Node
      attr_reader :line, :column

      def initialize(line = 0, column = 0)
        @line = line
        @column = column
      end
    end
  end
end
