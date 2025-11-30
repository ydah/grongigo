# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Variable declaration
    class VarDecl < Node
      attr_reader :type, :name, :initializer

      def initialize(type, name, initializer = nil, line = 0, column = 0)
        super(line, column)
        @type = type
        @name = name
        @initializer = initializer
      end
    end
  end
end
