# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Identifier
    class Identifier < Node
      attr_reader :name

      def initialize(name, line = 0, column = 0)
        super(line, column)
        @name = name
      end
    end
  end
end
