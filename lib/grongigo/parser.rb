# frozen_string_literal: true

require_relative 'lexer'
require_relative 'parse_error'
require_relative 'ast'

module Grongigo
  # Parser
  class Parser
    def initialize(tokens)
      @tokens = tokens
      @pos = 0
    end

    def parse
      declarations = []
      until check(:eof)
        decl = parse_declaration
        declarations << decl if decl
      end
      AST::Program.new(declarations)
    end

    private

    def current
      @tokens[@pos]
    end

    def previous
      @tokens[@pos - 1]
    end

    def check(type)
      # Special handling for EOF check
      return current.type == :eof if type == :eof
      return false if eof?

      current.type == type
    end

    def check_value(value)
      return false if eof?

      current.value == value
    end

    def eof?
      current.type == :eof
    end

    def advance
      @pos += 1 unless eof?
      previous
    end

    def match(*types)
      types.each do |type|
        if check(type)
          advance
          return true
        end
      end
      false
    end

    def match_value(*values)
      values.each do |value|
        if check_value(value)
          advance
          return true
        end
      end
      false
    end

    def consume(type, message)
      return advance if check(type)

      raise ParseError.new("#{message} at line #{current.line}, column #{current.column}", current)
    end

    def consume_value(value, message)
      return advance if check_value(value)

      raise ParseError.new("#{message} at line #{current.line}, column #{current.column}", current)
    end

    # Parse declaration
    def parse_declaration
      # EOF check
      return nil if check(:eof)

      # Function definition: パザ type name parameters block
      return parse_function_declaration if check(:other_keyword) && current.value == 'パザ'

      # Variable or function declaration starting with type
      return parse_var_or_func_declaration if check(:type_keyword)

      parse_statement
    end

    def parse_function_declaration
      advance # Skip パザ
      line = current.line
      column = current.column

      return_type = consume(:type_keyword, 'Expected return type').value
      name = parse_identifier_name

      # Parameters
      params = []

      # Parameters with parentheses
      if match(:open_paren)
        unless check(:close_paren)
          # No parameters if void only
          if check(:type_keyword) && current.value == 'void'
            advance
          else
            loop do
              param_type = consume(:type_keyword, 'Expected parameter type').value
              param_name = parse_identifier_name
              params << AST::Parameter.new(param_type, param_name)
              break unless match(:comma)
            end
          end
        end
        consume(:close_paren, 'Expected )')
      elsif check(:type_keyword) && current.value == 'void'
        # Without parentheses: if only type name then no arguments, otherwise parameter list
        # Example: パザ ゲギグウ ゴロ バサ ザジレ ... → main(void)
        advance # Skip void
      elsif check(:type_keyword)
        # If there are parameters
        loop do
          param_type = advance.value
          break if check(:open_brace) # End if block starts

          param_name = parse_identifier_name
          params << AST::Parameter.new(param_type, param_name)
          break unless match(:comma)
        end
      end

      body = parse_block
      AST::FunctionDecl.new(return_type, name, params, body, line, column)
    end

    def parse_var_or_func_declaration
      line = current.line
      column = current.column
      type = advance.value
      name = parse_identifier_name

      # Check for function declaration (whether there is a parameter list)
      if match(:open_paren)
        params = []
        unless check(:close_paren)
          loop do
            param_type = consume(:type_keyword, 'Expected parameter type').value
            param_name = parse_identifier_name
            params << AST::Parameter.new(param_type, param_name)
            break unless match(:comma)
          end
        end
        consume(:close_paren, 'Expected )')
        body = parse_block
        return AST::FunctionDecl.new(type, name, params, body, line, column)
      end

      # Variable declaration
      initializer = nil
      initializer = parse_expression if match(:operator) && previous.value == '='

      AST::VarDecl.new(type, name, initializer, line, column)
    end

    def parse_identifier_name
      if check(:identifier)
        advance.value
      elsif check(:other_keyword)
        advance.value
      else
        raise ParseError.new("Expected identifier at line #{current.line}", current)
      end
    end

    # Parse statement
    def parse_statement
      # EOFチェック
      return nil if check(:eof)

      line = current.line
      column = current.column

      # Block
      return parse_block if check(:open_brace)

      # if statement
      return parse_if_statement if check(:control_keyword) && current.value == 'if'

      # while statement
      return parse_while_statement if check(:control_keyword) && current.value == 'while'

      # for statement
      return parse_for_statement if check(:control_keyword) && current.value == 'for'

      # switch statement
      return parse_switch_statement if check(:control_keyword) && current.value == 'switch'

      # return statement
      return parse_return_statement if check(:control_keyword) && current.value == 'return'

      # break statement
      if check(:control_keyword) && current.value == 'break'
        advance
        return AST::BreakStmt.new(line, column)
      end

      # continue statement
      if check(:control_keyword) && current.value == 'continue'
        advance
        return AST::ContinueStmt.new(line, column)
      end

      # Variable declaration
      return parse_var_declaration if check(:type_keyword)

      # Expression statement
      parse_expression_statement
    end

    def parse_block
      line = current.line
      column = current.column
      consume(:open_brace, 'Expected {')

      statements = []
      until check(:close_brace) || eof?
        stmt = parse_statement
        statements << stmt if stmt
      end

      consume(:close_brace, 'Expected }')
      AST::BlockStmt.new(statements, line, column)
    end

    def parse_if_statement
      line = current.line
      column = current.column
      advance # Skip if

      condition = parse_expression
      then_branch = parse_block_or_statement

      else_branch = nil
      if check(:control_keyword) && current.value == 'else'
        advance
        # Check for else if
        else_branch = if check(:control_keyword) && current.value == 'if'
                        parse_if_statement
                      else
                        parse_block_or_statement
                      end
      end

      AST::IfStmt.new(condition, then_branch, else_branch, line, column)
    end

    def parse_while_statement
      line = current.line
      column = current.column
      advance # Skip while

      condition = parse_expression
      body = parse_block_or_statement

      AST::WhileStmt.new(condition, body, line, column)
    end

    def parse_for_statement
      line = current.line
      column = current.column
      advance # Skip for

      # Simple for statement: for init condition update block
      # Or with parentheses: for (init, condition, update) block

      init = nil
      condition = nil
      update = nil

      if match(:open_paren)
        init = parse_for_init unless check(:comma)
        consume(:comma, 'Expected ,')
        condition = parse_expression unless check(:comma)
        consume(:comma, 'Expected ,')
        update = parse_expression unless check(:close_paren)
        consume(:close_paren, 'Expected )')
      else
        # Without parentheses: condition only
        condition = parse_expression
      end

      body = parse_block_or_statement
      AST::ForStmt.new(init, condition, update, body, line, column)
    end

    def parse_for_init
      if check(:type_keyword)
        parse_var_declaration
      else
        parse_expression
      end
    end

    def parse_switch_statement
      line = current.line
      column = current.column
      advance # Skip switch

      expression = parse_expression
      consume(:open_brace, 'Expected {')

      cases = []
      default_case = nil

      until check(:close_brace) || eof?
        if check(:control_keyword) && current.value == 'case'
          advance
          value = parse_expression
          consume(:colon, 'Expected :')
          statements = []
          until check(:control_keyword) && %w[case default].include?(current.value) || check(:close_brace)
            statements << parse_statement
          end
          cases << AST::CaseClause.new(value, statements)
        elsif check(:control_keyword) && current.value == 'default'
          advance
          consume(:colon, 'Expected :')
          statements = []
          statements << parse_statement until check(:control_keyword) && current.value == 'case' || check(:close_brace)
          default_case = statements
        else
          break
        end
      end

      consume(:close_brace, 'Expected }')
      AST::SwitchStmt.new(expression, cases, default_case, line, column)
    end

    def parse_return_statement
      line = current.line
      column = current.column
      advance # Skip return

      value = nil
      # Parse value if not block end or EOF
      unless check(:close_brace) || check(:eof) || check(:control_keyword) || check(:type_keyword)
        value = parse_expression
      end

      AST::ReturnStmt.new(value, line, column)
    end

    def parse_var_declaration
      line = current.line
      column = current.column
      type = advance.value
      name = parse_identifier_name

      # Array declaration
      if match(:open_bracket)
        # Array size
        parse_expression unless check(:close_bracket)
        consume(:close_bracket, 'Expected ]')
        type = "#{type}[]"
      end

      initializer = nil
      if check(:operator) && current.value == '='
        advance
        initializer = parse_expression
      end

      AST::VarDecl.new(type, name, initializer, line, column)
    end

    def parse_block_or_statement
      if check(:open_brace)
        parse_block
      else
        parse_statement
      end
    end

    def parse_expression_statement
      line = current.line
      column = current.column
      expr = parse_expression
      AST::ExprStmt.new(expr, line, column)
    end

    # Parse expression（優先順位順）
    def parse_expression
      parse_assignment
    end

    def parse_assignment
      expr = parse_or

      if check(:operator) && current.value == '='
        advance
        value = parse_assignment
        return AST::AssignExpr.new(expr, value, expr.line, expr.column)
      end

      expr
    end

    def parse_or
      expr = parse_and

      while check(:operator) && current.value == '||'
        op = advance.value
        right = parse_and
        expr = AST::BinaryExpr.new(expr, op, right, expr.line, expr.column)
      end

      expr
    end

    def parse_and
      expr = parse_equality

      while check(:operator) && current.value == '&&'
        op = advance.value
        right = parse_equality
        expr = AST::BinaryExpr.new(expr, op, right, expr.line, expr.column)
      end

      expr
    end

    def parse_equality
      expr = parse_comparison

      while check(:operator) && %w[== !=].include?(current.value)
        op = advance.value
        right = parse_comparison
        expr = AST::BinaryExpr.new(expr, op, right, expr.line, expr.column)
      end

      expr
    end

    def parse_comparison
      expr = parse_term

      while check(:operator) && %w[< > <= >=].include?(current.value)
        op = advance.value
        right = parse_term
        expr = AST::BinaryExpr.new(expr, op, right, expr.line, expr.column)
      end

      expr
    end

    def parse_term
      expr = parse_factor

      while check(:operator) && %w[+ -].include?(current.value)
        op = advance.value
        right = parse_factor
        expr = AST::BinaryExpr.new(expr, op, right, expr.line, expr.column)
      end

      expr
    end

    def parse_factor
      expr = parse_unary

      while check(:operator) && %w[* / %].include?(current.value)
        op = advance.value
        right = parse_unary
        expr = AST::BinaryExpr.new(expr, op, right, expr.line, expr.column)
      end

      expr
    end

    def parse_unary
      if check(:operator) && %w[! - ++ --].include?(current.value)
        op = advance.value
        operand = parse_unary
        return AST::UnaryExpr.new(op, operand, true, operand.line, operand.column)
      end

      parse_postfix
    end

    def parse_postfix
      expr = parse_primary

      loop do
        if match(:open_paren)
          # Function call
          args = []
          unless check(:close_paren)
            loop do
              args << parse_expression
              break unless match(:comma)
            end
          end
          consume(:close_paren, 'Expected )')
          expr = AST::CallExpr.new(expr, args, expr.line, expr.column)
        elsif match(:open_bracket)
          # Array access
          index = parse_expression
          consume(:close_bracket, 'Expected ]')
          expr = AST::IndexExpr.new(expr, index, expr.line, expr.column)
        elsif check(:operator) && %w[++ --].include?(current.value)
          op = advance.value
          expr = AST::UnaryExpr.new(op, expr, false, expr.line, expr.column)
        else
          break
        end
      end

      expr
    end

    def parse_primary
      line = current.line
      column = current.column

      # Number literal
      if check(:number)
        advance
        return AST::NumberLiteral.new(previous.value, line, column)
      end

      # String literal
      return AST::StringLiteral.new(previous.value, line, column) if match(:string_literal)

      # Character literal
      return AST::CharLiteral.new(previous.value, line, column) if match(:char_literal)

      # Identifier
      return AST::Identifier.new(previous.value, line, column) if match(:identifier)

      # Keyword used as identifier
      return AST::Identifier.new(previous.value, line, column) if match(:other_keyword)

      # Control keyword (function name like printf)
      return AST::Identifier.new(previous.value, line, column) if match(:control_keyword)

      # Parentheses
      if match(:open_paren)
        expr = parse_expression
        consume(:close_paren, 'Expected )')
        return expr
      end

      raise ParseError.new("Unexpected token: #{current.value.inspect} (type: #{current.type}) at line #{line}",
                           current)
    end
  end
end
