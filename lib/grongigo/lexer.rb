# frozen_string_literal: true

require_relative 'constants'
require_relative 'token'

module Grongigo
  # Lexical analyzer
  class Lexer
    # Token types
    TOKEN_TYPES = %i[
      type_keyword
      control_keyword
      builtin_keyword
      literal_keyword
      other_keyword
      operator
      number
      identifier
      string_literal
      char_literal
      open_brace
      close_brace
      open_paren
      close_paren
      open_bracket
      close_bracket
      comma
      semicolon
      colon
      newline
      eof
    ].freeze

    STRING_LITERAL_OPEN = 'ジサビロジセヅ'
    STRING_LITERAL_CLOSE = 'ドジロジセヅ'
    CHAR_LITERAL_OPEN = 'ジサビジドロジ'
    CHAR_LITERAL_CLOSE = 'ドジジドロジ'

    SYNTAX_KEYWORDS = {
      'ジサビバッボ' => [:open_paren, '('],
      'ドジバッボ' => [:close_paren, ')'],
      'ジサビバブバッボ' => [:open_bracket, '['],
      'ドジバブバッボ' => [:close_bracket, ']'],
      'ザジレ' => [:open_brace, '{'],
      'ゴパシ' => [:close_brace, '}']
    }.freeze

    RESERVED_KEYWORD_GROUPS = [
      [TYPE_KEYWORDS, :type_keyword],
      [CONTROL_KEYWORDS, :control_keyword],
      [BUILTIN_KEYWORDS, :builtin_keyword],
      [LITERAL_KEYWORDS, :literal_keyword],
      [OTHER_KEYWORDS, :other_keyword],
      [OPERATORS, :operator]
    ].freeze

    def initialize(source)
      @source = source
      @pos = 0
      @line = 1
      @column = 1
      @tokens = []
    end

    def tokenize
      @tokens = []

      until eof?
        skip_whitespace_and_comments
        break if eof?

        token = next_token
        @tokens << token if token
      end

      @tokens << Token.new(:eof, nil, @line, @column)
      @tokens
    end

    private

    def eof?
      @pos >= @source.length
    end

    def current_char
      @source[@pos]
    end

    def peek(n = 1)
      @source[@pos, n]
    end

    def advance(n = 1)
      n.times do
        if current_char == "\n"
          @line += 1
          @column = 1
        else
          @column += 1
        end
        @pos += 1
      end
    end

    def skip_whitespace_and_comments
      loop do
        # Skip whitespace (except newlines)
        advance while !eof? && current_char =~ /[ \t\r]/

        # Newline
        if !eof? && current_char == "\n"
          advance
          next
        end

        # Simple line comment starting with "ゴゴ" (equivalent to //)
        if peek(2) == 'ゴゴ'
          advance(2)
          advance until eof? || current_char == "\n"
          next
        end

        # Block comment (equivalent to /* */): "ゴビ" to "ビゴ"
        if peek(2) == 'ゴビ'
          advance(2)
          until eof?
            if peek(2) == 'ビゴ'
              advance(2)
              break
            end
            advance
          end
          next
        end

        break
      end
    end

    def next_token
      start_line = @line
      start_column = @column

      # String literal
      if peek(STRING_LITERAL_OPEN.length) == STRING_LITERAL_OPEN
        return scan_string_literal(start_line, start_column)
      end

      # Character literal
      if peek(CHAR_LITERAL_OPEN.length) == CHAR_LITERAL_OPEN
        return scan_char_literal(start_line, start_column)
      end

      # Brackets and delimiters
      case current_char
      when '、', ','
        advance
        return Token.new(:comma, ',', start_line, start_column)
      when '。'
        advance
        return Token.new(:semicolon, ';', start_line, start_column)
      when '：', ':'
        advance
        return Token.new(:colon, ':', start_line, start_column)
      end

      # Katakana-based identifier/keyword/number
      return scan_katakana_word(start_line, start_column) if current_char =~ /\p{Katakana}/

      # ASCII characters (allowed as variable names)
      return scan_ascii_identifier(start_line, start_column) if current_char =~ /[a-zA-Z_]/

      # Digits (decimal literals allowed, converted to base-9 later)
      return scan_decimal_number(start_line, start_column) if current_char =~ /[0-9]/

      # Unknown character
      char = current_char
      advance
      Token.new(:unknown, char, start_line, start_column)
    end

    def scan_string_literal(start_line, start_column)
      scan_delimited_literal(
        start_line,
        start_column,
        STRING_LITERAL_OPEN,
        STRING_LITERAL_CLOSE,
        :string_literal
      )
    end

    def scan_char_literal(start_line, start_column)
      scan_delimited_literal(
        start_line,
        start_column,
        CHAR_LITERAL_OPEN,
        CHAR_LITERAL_CLOSE,
        :char_literal
      )
    end

    def scan_delimited_literal(start_line, start_column, opening, closing, token_type)
      advance(opening.length)
      value = ''
      until eof? || peek(closing.length) == closing
        value += current_char
        advance
      end
      advance(closing.length) if peek(closing.length) == closing
      Token.new(token_type, value, start_line, start_column)
    end

    def scan_katakana_word(start_line, start_column)
      word = ''
      while !eof? && current_char =~ /[\p{Katakana}ー]/
        word += current_char
        advance
      end

      # Classify as keyword, operator, or number
      token_type, token_value = classify_katakana_word(word)
      Token.new(token_type, token_value, start_line, start_column)
    end

    def classify_katakana_word(word)
      # Split syntax delimiters from the following token when there is no whitespace.
      syntax_token = match_prefixed_token(word, SYNTAX_KEYWORDS)
      return syntax_token if syntax_token

      # Split reserved words before syntax delimiters, e.g. ジョウジジサビバッボ.
      reserved_token = match_reserved_prefix_before_syntax(word)
      return reserved_token if reserved_token

      # Type keywords
      return [:type_keyword, TYPE_KEYWORDS[word]] if TYPE_KEYWORDS.key?(word)

      # Control keywords
      return [:control_keyword, CONTROL_KEYWORDS[word]] if CONTROL_KEYWORDS.key?(word)

      # Built-in keywords
      return [:builtin_keyword, BUILTIN_KEYWORDS[word]] if BUILTIN_KEYWORDS.key?(word)

      # Literal keywords
      return [:literal_keyword, LITERAL_KEYWORDS[word]] if LITERAL_KEYWORDS.key?(word)

      # Other keywords
      if OTHER_KEYWORDS.key?(word)
        value = OTHER_KEYWORDS[word]
        return [:other_keyword, value.empty? ? word : value]
      end

      # Operators
      return [:operator, OPERATORS[word]] if OPERATORS.key?(word)

      # Try to parse as number
      number = try_parse_number(word)
      return [:number, number] if number

      # Identifier (variable name, etc.)
      [:identifier, word]
    end

    def match_prefixed_token(word, token_map)
      token_map.keys.sort_by { |k| -k.length }.each do |keyword|
        next unless word.start_with?(keyword)

        rewind_excess(word.length - keyword.length)
        return token_map[keyword]
      end

      nil
    end

    def match_reserved_prefix_before_syntax(word)
      RESERVED_KEYWORD_GROUPS.each do |keyword_map, token_type|
        keyword_map.keys.sort_by { |k| -k.length }.each do |keyword|
          next unless word.start_with?(keyword)

          rest = word[keyword.length..]
          next if rest.nil? || rest.empty?
          next unless syntax_delimiter_prefix?(rest)

          rewind_excess(word.length - keyword.length)
          value = keyword_map[keyword]
          value = keyword if token_type == :other_keyword && value.empty?
          return [token_type, value]
        end
      end

      nil
    end

    def syntax_delimiter_prefix?(word)
      SYNTAX_KEYWORDS.keys.any? { |keyword| word.start_with?(keyword) } ||
        word.start_with?(STRING_LITERAL_OPEN) ||
        word.start_with?(CHAR_LITERAL_OPEN)
    end

    def rewind_excess(excess)
      return if excess <= 0

      @pos -= excess
      @column -= excess
    end

    def try_parse_number(word)
      # Single digit
      return DIGITS[word] if DIGITS.key?(word)

      # Parse compound number (e.g., バギンドパパン = 9 + 1 = 10)
      parse_compound_number(word)
    end

    def parse_compound_number(word)
      return nil if word.empty?

      # Tokenize the expression
      tokens = tokenize_number_expression(word)
      return nil if tokens.empty?

      # Evaluate the expression
      evaluate_number_expression(tokens)
    rescue StandardError
      nil
    end

    def tokenize_number_expression(word)
      tokens = []
      remaining = word

      until remaining.empty?
        matched = false

        # Check digits (longest first)
        DIGITS.keys.sort_by { |k| -k.length }.each do |digit_word|
          next unless remaining.start_with?(digit_word)

          tokens << [:digit, DIGITS[digit_word]]
          remaining = remaining[digit_word.length..]
          matched = true
          break
        end
        next if matched

        # Check operators
        if remaining.start_with?('ド')
          tokens << [:add, nil]
          remaining = remaining[1..]
          matched = true
        elsif remaining.start_with?('グ')
          tokens << [:multiply, nil]
          remaining = remaining[1..]
          matched = true
        end

        break unless matched
      end

      return [] unless remaining.empty?

      tokens
    end

    def evaluate_number_expression(tokens)
      return nil if tokens.empty?

      # Process multiplication first by grouping
      # Example: バギングバギンドパパン = (9*9) + 1 = 82

      result = 0
      current_product = nil

      i = 0
      while i < tokens.length
        token = tokens[i]

        case token[0]
        when :digit
          # Error if digit appears without preceding operator
          return nil unless current_product.nil?

          current_product = token[1]
        when :multiply
          # Multiply with next digit
          i += 1
          return nil if i >= tokens.length || tokens[i][0] != :digit

          current_product = (current_product || 1) * tokens[i][1]
        when :add
          # Add current product to result and reset
          result += current_product if current_product
          current_product = nil
        end

        i += 1
      end

      result += current_product if current_product
      result
    end

    def scan_ascii_identifier(start_line, start_column)
      word = ''
      while !eof? && current_char =~ /[a-zA-Z0-9_]/
        word += current_char
        advance
      end
      Token.new(:identifier, word, start_line, start_column)
    end

    def scan_decimal_number(start_line, start_column)
      word = ''
      while !eof? && current_char =~ /[0-9.]/
        word += current_char
        advance
      end

      # Determine if integer or floating point
      if word.include?('.')
        Token.new(:number, word.to_f, start_line, start_column)
      else
        Token.new(:number, word.to_i, start_line, start_column)
      end
    end
  end
end
