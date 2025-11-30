# frozen_string_literal: true

module Grongigo
  # Token type
  class Token
    attr_reader :type, :value, :line, :column

    def initialize(type, value, line = 0, column = 0)
      @type = type
      @value = value
      @line = line
      @column = column
    end

    def to_s
      "Token(#{@type}, #{@value.inspect}, L#{@line}:#{@column})"
    end

    def inspect
      to_s
    end
  end
end
