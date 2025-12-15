# frozen_string_literal: true

require_relative 'parser'

module Grongigo
  # C code generator
  class CodeGenerator
    def initialize
      @indent_level = 0
      @output = []
    end

    def generate(ast)
      @output = []

      # Standard headers
      emit '#include <stdio.h>'
      emit '#include <stdlib.h>'
      emit '#include <string.h>'
      emit ''

      # Generate each declaration
      ast.declarations.each do |decl|
        generate_declaration(decl)
        emit ''
      end

      @output.join("\n")
    end

    private

    def emit(code)
      @output << ('    ' * @indent_level + code)
    end

    def indent
      @indent_level += 1
    end

    def dedent
      @indent_level -= 1
    end

    def generate_declaration(node)
      case node
      when AST::FunctionDecl
        generate_function(node)
      when AST::VarDecl
        generate_var_decl(node)
      else
        generate_statement(node)
      end
    end

    def generate_function(node)
      params = node.params.map { |p| "#{p.type} #{sanitize_name(p.name)}" }.join(', ')
      params = 'void' if params.empty? && node.name == 'main'

      emit "#{node.return_type} #{sanitize_name(node.name)}(#{params})"
      generate_block(node.body)
    end

    def generate_block(node)
      emit '{'
      indent
      node.statements.each { |stmt| generate_statement(stmt) }
      dedent
      emit '}'
    end

    def generate_statement(node)
      case node
      when AST::BlockStmt
        generate_block(node)
      when AST::VarDecl
        generate_var_decl(node)
      when AST::IfStmt
        generate_if(node)
      when AST::WhileStmt
        generate_while(node)
      when AST::ForStmt
        generate_for(node)
      when AST::SwitchStmt
        generate_switch(node)
      when AST::ReturnStmt
        generate_return(node)
      when AST::BreakStmt
        emit 'break;'
      when AST::ContinueStmt
        emit 'continue;'
      when AST::ExprStmt
        emit "#{generate_expr(node.expression)};"
      else
        raise "Unknown statement type: #{node.class}"
      end
    end

    def generate_var_decl(node)
      name = sanitize_name(node.name)
      type = node.type

      # Handle array types
      if type.end_with?('[]')
        base_type = type[0..-3]
        if node.initializer
          emit "#{base_type} #{name}[] = #{generate_expr(node.initializer)};"
        else
          emit "#{base_type} #{name}[];"
        end
      elsif node.initializer
        emit "#{type} #{name} = #{generate_expr(node.initializer)};"
      else
        emit "#{type} #{name};"
      end
    end

    def generate_if(node)
      emit "if (#{generate_expr(node.condition)})"
      if node.then_branch.is_a?(AST::BlockStmt)
        generate_block(node.then_branch)
      else
        indent
        generate_statement(node.then_branch)
        dedent
      end

      return unless node.else_branch

      if node.else_branch.is_a?(AST::IfStmt)
        @output[-1] = @output[-1] # Keep previous closing brace
        # Put else if on same line
        @output << ('    ' * @indent_level + 'else')
        generate_if_as_else(node.else_branch)
      elsif node.else_branch.is_a?(AST::BlockStmt)
        emit 'else'
        generate_block(node.else_branch)
      else
        emit 'else'
        indent
        generate_statement(node.else_branch)
        dedent
      end
    end

    def generate_if_as_else(node)
      @output[-1] += " if (#{generate_expr(node.condition)})"
      if node.then_branch.is_a?(AST::BlockStmt)
        generate_block(node.then_branch)
      else
        indent
        generate_statement(node.then_branch)
        dedent
      end

      return unless node.else_branch

      if node.else_branch.is_a?(AST::IfStmt)
        @output << ('    ' * @indent_level + 'else')
        generate_if_as_else(node.else_branch)
      elsif node.else_branch.is_a?(AST::BlockStmt)
        emit 'else'
        generate_block(node.else_branch)
      else
        emit 'else'
        indent
        generate_statement(node.else_branch)
        dedent
      end
    end

    def generate_while(node)
      emit "while (#{generate_expr(node.condition)})"
      if node.body.is_a?(AST::BlockStmt)
        generate_block(node.body)
      else
        indent
        generate_statement(node.body)
        dedent
      end
    end

    def generate_for(node)
      init = node.init ? generate_for_init(node.init) : ''
      cond = node.condition ? generate_expr(node.condition) : ''
      update = node.update ? generate_expr(node.update) : ''

      emit "for (#{init}; #{cond}; #{update})"
      if node.body.is_a?(AST::BlockStmt)
        generate_block(node.body)
      else
        indent
        generate_statement(node.body)
        dedent
      end
    end

    def generate_for_init(node)
      case node
      when AST::VarDecl
        name = sanitize_name(node.name)
        if node.initializer
          "#{node.type} #{name} = #{generate_expr(node.initializer)}"
        else
          "#{node.type} #{name}"
        end
      else
        generate_expr(node)
      end
    end

    def generate_switch(node)
      emit "switch (#{generate_expr(node.expression)})"
      emit '{'
      indent

      node.cases.each do |c|
        dedent
        emit "case #{generate_expr(c.value)}:"
        indent
        c.statements.each { |stmt| generate_statement(stmt) }
      end

      if node.default_case
        dedent
        emit 'default:'
        indent
        node.default_case.each { |stmt| generate_statement(stmt) }
      end

      dedent
      emit '}'
    end

    def generate_return(node)
      if node.value
        emit "return #{generate_expr(node.value)};"
      else
        emit 'return;'
      end
    end

    def generate_call_expr(node)
      callee_name = node.callee.is_a?(AST::Identifier) ? node.callee.name : nil
      is_printf = callee_name == 'printf' || callee_name == 'ジョウジ'

      # For printf, automatically add \n to string literals if not present
      if is_printf && !node.arguments.empty? && node.arguments[0].is_a?(AST::StringLiteral)
        first_arg = node.arguments[0]
        str_value = first_arg.value

        # Add \n if not already present
        unless str_value.end_with?("\\n") || str_value.end_with?("\n")
          str_value += "\\n"
        end

        # Generate modified first argument
        modified_first = "\"#{escape_string(str_value)}\""

        # Generate remaining arguments
        remaining_args = node.arguments[1..].map { |a| generate_expr(a) }

        all_args = [modified_first] + remaining_args
        "#{generate_expr(node.callee)}(#{all_args.join(', ')})"
      else
        # Normal function call
        args = node.arguments.map { |a| generate_expr(a) }.join(', ')
        "#{generate_expr(node.callee)}(#{args})"
      end
    end

    def generate_expr(node)
      case node
      when AST::BinaryExpr
        "(#{generate_expr(node.left)} #{node.operator} #{generate_expr(node.right)})"
      when AST::UnaryExpr
        if node.prefix
          "#{node.operator}#{generate_expr(node.operand)}"
        else
          "#{generate_expr(node.operand)}#{node.operator}"
        end
      when AST::AssignExpr
        "#{generate_expr(node.target)} = #{generate_expr(node.value)}"
      when AST::CallExpr
        generate_call_expr(node)
      when AST::IndexExpr
        "#{generate_expr(node.array)}[#{generate_expr(node.index)}]"
      when AST::Identifier
        sanitize_name(node.name)
      when AST::NumberLiteral
        node.value.to_s
      when AST::StringLiteral
        "\"#{escape_string(node.value)}\""
      when AST::CharLiteral
        "'#{escape_char(node.value)}'"
      else
        raise "Unknown expression type: #{node.class}"
      end
    end

    def sanitize_name(name)
      # Convert Grongigo variable names to valid C names
      return name if name =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/

      # Special keywords
      return name if %w[main printf scanf NULL].include?(name)

      # Convert katakana to roman alphabets
      katakana2roman(name)
    end

    def katakana2roman(text)
      # Simple katakana to roman alphabet mapping
      map = {
        'ア' => 'a', 'イ' => 'i', 'ウ' => 'u', 'エ' => 'e', 'オ' => 'o',
        'カ' => 'ka', 'キ' => 'ki', 'ク' => 'ku', 'ケ' => 'ke', 'コ' => 'ko',
        'サ' => 'sa', 'シ' => 'si', 'ス' => 'su', 'セ' => 'se', 'ソ' => 'so',
        'タ' => 'ta', 'チ' => 'ti', 'ツ' => 'tu', 'テ' => 'te', 'ト' => 'to',
        'ナ' => 'na', 'ニ' => 'ni', 'ヌ' => 'nu', 'ネ' => 'ne', 'ノ' => 'no',
        'ハ' => 'ha', 'ヒ' => 'hi', 'フ' => 'hu', 'ヘ' => 'he', 'ホ' => 'ho',
        'マ' => 'ma', 'ミ' => 'mi', 'ム' => 'mu', 'メ' => 'me', 'モ' => 'mo',
        'ヤ' => 'ya', 'ユ' => 'yu', 'ヨ' => 'yo',
        'ラ' => 'ra', 'リ' => 'ri', 'ル' => 'ru', 'レ' => 're', 'ロ' => 'ro',
        'ワ' => 'wa', 'ヲ' => 'wo', 'ン' => 'n',
        'ガ' => 'ga', 'ギ' => 'gi', 'グ' => 'gu', 'ゲ' => 'ge', 'ゴ' => 'go',
        'ザ' => 'za', 'ジ' => 'zi', 'ズ' => 'zu', 'ゼ' => 'ze', 'ゾ' => 'zo',
        'ダ' => 'da', 'ヂ' => 'di', 'ヅ' => 'du', 'デ' => 'de', 'ド' => 'do',
        'バ' => 'ba', 'ビ' => 'bi', 'ブ' => 'bu', 'ベ' => 'be', 'ボ' => 'bo',
        'パ' => 'pa', 'ピ' => 'pi', 'プ' => 'pu', 'ペ' => 'pe', 'ポ' => 'po',
        'ジャ' => 'ja', 'ジュ' => 'ju', 'ジョ' => 'jo',
        'ー' => '_'
      }

      result = ''
      i = 0
      while i < text.length
        # Check for 2-character combinations
        if i + 1 < text.length && map.key?(text[i, 2])
          result += map[text[i, 2]]
          i += 2
        elsif map.key?(text[i])
          result += map[text[i]]
          i += 1
        else
          # Convert unmappable characters to underscore
          result += '_'
          i += 1
        end
      end

      # Ensure result doesn't start with a digit
      result = "_#{result}" if result =~ /^[0-9]/
      result = 'var' if result.empty?
      result
    end

    def escape_string(str)
      str.gsub('\\', '\\\\')
         .gsub('"', '\\"')
         .gsub("\n", '\\n')
         .gsub("\t", '\\t')
         .gsub("\r", '\\r')
    end

    def escape_char(str)
      return '\\0' if str.empty?

      char = str[0]
      case char
      when '\\'
        '\\\\'
      when "'"
        "\\'"
      when "\n"
        '\\n'
      when "\t"
        '\\t'
      when "\r"
        '\\r'
      else
        char
      end
    end
  end
end
