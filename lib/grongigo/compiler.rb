# frozen_string_literal: true

require_relative 'lexer'
require_relative 'parser'
require_relative 'codegen'

module Grongigo
  # Main compiler class
  class Compiler
    attr_reader :errors

    def initialize(options = {})
      @options = {
        verbose: false,
        output_tokens: false,
        output_ast: false
      }.merge(options)
      @errors = []
    end

    def compile(source)
      @errors = []

      # Lexical analysis
      log 'Starting lexical analysis...'
      lexer = Lexer.new(source)
      tokens = lexer.tokenize

      if @options[:output_tokens]
        puts '=== Tokens ==='
        tokens.each { |t| puts t }
        puts ''
      end

      # Parsing
      log 'Starting parsing...'
      parser = Parser.new(tokens)
      ast = parser.parse

      if @options[:output_ast]
        puts '=== AST ==='
        print_ast(ast)
        puts ''
      end

      # Code generation
      log 'Generating C code...'
      generator = CodeGenerator.new
      c_code = generator.generate(ast)

      log 'Compilation successful!'
      c_code
    rescue ParseError => e
      @errors << "Parse error: #{e.message}"
      nil
    rescue StandardError => e
      @errors << "Error: #{e.message}"
      @errors << e.backtrace.first(5).join("\n") if @options[:verbose]
      nil
    end

    def compile_file(input_path, output_path = nil)
      output_path ||= input_path.sub(/\.[^.]+$/, '.c')

      source = File.read(input_path, encoding: 'UTF-8')
      c_code = compile(source)

      return false unless c_code

      File.write(output_path, c_code, encoding: 'UTF-8')
      log "Output written to: #{output_path}"
      true
    end

    private

    def log(message)
      puts "[Grongigo] #{message}" if @options[:verbose]
    end

    def print_ast(node, indent = 0)
      prefix = '  ' * indent
      case node
      when AST::Program
        puts "#{prefix}Program"
        node.declarations.each { |d| print_ast(d, indent + 1) }
      when AST::FunctionDecl
        puts "#{prefix}FunctionDecl: #{node.return_type} #{node.name}"
        node.params.each { |p| print_ast(p, indent + 1) }
        print_ast(node.body, indent + 1)
      when AST::Parameter
        puts "#{prefix}Parameter: #{node.type} #{node.name}"
      when AST::VarDecl
        puts "#{prefix}VarDecl: #{node.type} #{node.name}"
        print_ast(node.initializer, indent + 1) if node.initializer
      when AST::BlockStmt
        puts "#{prefix}BlockStmt"
        node.statements.each { |s| print_ast(s, indent + 1) }
      when AST::IfStmt
        puts "#{prefix}IfStmt"
        print_ast(node.condition, indent + 1)
        print_ast(node.then_branch, indent + 1)
        print_ast(node.else_branch, indent + 1) if node.else_branch
      when AST::WhileStmt
        puts "#{prefix}WhileStmt"
        print_ast(node.condition, indent + 1)
        print_ast(node.body, indent + 1)
      when AST::ForStmt
        puts "#{prefix}ForStmt"
        print_ast(node.init, indent + 1) if node.init
        print_ast(node.condition, indent + 1) if node.condition
        print_ast(node.update, indent + 1) if node.update
        print_ast(node.body, indent + 1)
      when AST::ReturnStmt
        puts "#{prefix}ReturnStmt"
        print_ast(node.value, indent + 1) if node.value
      when AST::BreakStmt
        puts "#{prefix}BreakStmt"
      when AST::ContinueStmt
        puts "#{prefix}ContinueStmt"
      when AST::ExprStmt
        puts "#{prefix}ExprStmt"
        print_ast(node.expression, indent + 1)
      when AST::BinaryExpr
        puts "#{prefix}BinaryExpr: #{node.operator}"
        print_ast(node.left, indent + 1)
        print_ast(node.right, indent + 1)
      when AST::UnaryExpr
        puts "#{prefix}UnaryExpr: #{node.operator} (prefix=#{node.prefix})"
        print_ast(node.operand, indent + 1)
      when AST::AssignExpr
        puts "#{prefix}AssignExpr"
        print_ast(node.target, indent + 1)
        print_ast(node.value, indent + 1)
      when AST::CallExpr
        puts "#{prefix}CallExpr"
        print_ast(node.callee, indent + 1)
        node.arguments.each { |a| print_ast(a, indent + 1) }
      when AST::IndexExpr
        puts "#{prefix}IndexExpr"
        print_ast(node.array, indent + 1)
        print_ast(node.index, indent + 1)
      when AST::Identifier
        puts "#{prefix}Identifier: #{node.name}"
      when AST::NumberLiteral
        puts "#{prefix}NumberLiteral: #{node.value}"
      when AST::StringLiteral
        puts "#{prefix}StringLiteral: #{node.value.inspect}"
      when AST::CharLiteral
        puts "#{prefix}CharLiteral: #{node.value.inspect}"
      else
        puts "#{prefix}Unknown: #{node.class}"
      end
    end
  end
end
