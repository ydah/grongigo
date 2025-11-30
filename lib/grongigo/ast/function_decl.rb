# frozen_string_literal: true

require_relative 'node'

module Grongigo
  module AST
    # 関数定義
    class FunctionDecl < Node
      attr_reader :return_type, :name, :params, :body

      def initialize(return_type, name, params, body, line = 0, column = 0)
        super(line, column)
        @return_type = return_type
        @name = name
        @params = params
        @body = body
      end
    end
  end
end
