# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # Parameters
    class Parameter < Node
      attr_reader :type, :name

      def initialize(type, name, line = 0, column = 0)
        super(line, column)
        @type = type
        @name = name
      end
    end
  end
end
