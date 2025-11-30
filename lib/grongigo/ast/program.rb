# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # プログラム全体
    class Program < Node
      attr_reader :declarations

      def initialize(declarations)
        super(0, 0)
        @declarations = declarations
      end
    end
  end
end
