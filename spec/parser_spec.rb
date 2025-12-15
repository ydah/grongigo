# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Grongigo::Parser do
  def tokenize(source)
    Grongigo::Lexer.new(source).tokenize
  end

  describe '#parse' do
    context 'with function declarations' do
      it 'parses a simple void function' do
        source = 'パザ バサ デギド バサ ザジレ ゴパシ'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        expect(ast).to be_a(Grongigo::AST::Program)
        expect(ast.declarations.length).to eq(1)

        func = ast.declarations[0]
        expect(func).to be_a(Grongigo::AST::FunctionDecl)
        expect(func.return_type).to eq('void')
        expect(func.name).to eq('デギド')
        expect(func.params).to be_empty
      end

      it 'parses a function with parameters' do
        source = 'パザ ゲギグウ ダギ ゲギグウ バ、ゲギグウ ダ ザジレ ゴパシ'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        expect(func.return_type).to eq('int')
        expect(func.name).to eq('ダギ')
        expect(func.params.length).to eq(2)
        expect(func.params[0].type).to eq('int')
        expect(func.params[0].name).to eq('バ')
        expect(func.params[1].type).to eq('int')
        expect(func.params[1].name).to eq('ダ')
      end

    end

    context 'with variable declarations' do
      it 'parses a simple variable declaration' do
        source = 'ゲギグウ バ'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        var = ast.declarations[0]
        expect(var).to be_a(Grongigo::AST::VarDecl)
        expect(var.type).to eq('int')
        expect(var.name).to eq('バ')
        expect(var.initializer).to be_nil
      end

      it 'parses a variable declaration with initializer' do
        source = 'ゲギグウ バ ギセス パパン'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        var = ast.declarations[0]
        expect(var.type).to eq('int')
        expect(var.name).to eq('バ')
        expect(var.initializer).to be_a(Grongigo::AST::NumberLiteral)
        expect(var.initializer.value).to eq(1)
      end
    end

    context 'with statements' do
      it 'parses if statement' do
        source = <<~GRONGIGO
          パザ バサ デギド バサ ザジレ
            ジョウベン バ ザジレ
              ロゾス
            ゴパシ
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        if_stmt = func.body.statements[0]
        expect(if_stmt).to be_a(Grongigo::AST::IfStmt)
        expect(if_stmt.condition).to be_a(Grongigo::AST::Identifier)
        expect(if_stmt.then_branch).to be_a(Grongigo::AST::BlockStmt)
      end

      it 'parses if-else statement' do
        source = <<~GRONGIGO
          パザ バサ デギド バサ ザジレ
            ジョウベン バ ザジレ
              ロゾス
            ゴパシ ゾバ ザジレ
              ロゾス
            ゴパシ
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        if_stmt = func.body.statements[0]
        expect(if_stmt).to be_a(Grongigo::AST::IfStmt)
        expect(if_stmt.else_branch).to be_a(Grongigo::AST::BlockStmt)
      end

      it 'parses while statement' do
        source = <<~GRONGIGO
          パザ バサ デギド バサ ザジレ
            ガギザ バ ザジレ
              ロゾス
            ゴパシ
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        while_stmt = func.body.statements[0]
        expect(while_stmt).to be_a(Grongigo::AST::WhileStmt)
        expect(while_stmt.condition).to be_a(Grongigo::AST::Identifier)
        expect(while_stmt.body).to be_a(Grongigo::AST::BlockStmt)
      end

      it 'parses for statement' do
        source = <<~GRONGIGO
          パザ バサ デギド バサ ザジレ
            ブシバゲギ ザジレジョヂザギゲギグウ ギ ギセス ゼゼソ、ギ ギョウバシ バギン、ギ ダグダグ ゴパシジョヂザギ ザジレ
              ロゾス
            ゴパシ
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        for_stmt = func.body.statements[0]
        expect(for_stmt).to be_a(Grongigo::AST::ForStmt)
        expect(for_stmt.init).to be_a(Grongigo::AST::VarDecl)
        expect(for_stmt.condition).to be_a(Grongigo::AST::BinaryExpr)
        expect(for_stmt.update).to be_a(Grongigo::AST::UnaryExpr)
      end

      it 'parses return statement' do
        source = <<~GRONGIGO
          パザ ゲギグウ test バサ ザジレ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        return_stmt = func.body.statements[0]
        expect(return_stmt).to be_a(Grongigo::AST::ReturnStmt)
        expect(return_stmt.value).to be_a(Grongigo::AST::NumberLiteral)
      end

      it 'parses break statement' do
        source = <<~GRONGIGO
          パザ バサ デギド バサ ザジレ
            ブゲス
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        break_stmt = func.body.statements[0]
        expect(break_stmt).to be_a(Grongigo::AST::BreakStmt)
      end

      it 'parses continue statement' do
        source = <<~GRONGIGO
          パザ バサ デギド バサ ザジレ
            ヅヅゲス
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        continue_stmt = func.body.statements[0]
        expect(continue_stmt).to be_a(Grongigo::AST::ContinueStmt)
      end
    end

    context 'with expressions' do
      it 'parses binary expressions' do
        source = 'ゲギグウ セギャスド ギセス バ ダグ ダ'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        var_decl = ast.declarations[0]
        binary_expr = var_decl.initializer
        expect(binary_expr).to be_a(Grongigo::AST::BinaryExpr)
        expect(binary_expr.operator).to eq('+')
        expect(binary_expr.left).to be_a(Grongigo::AST::Identifier)
        expect(binary_expr.right).to be_a(Grongigo::AST::Identifier)
      end

      it 'parses unary expressions' do
        source = 'ゲギグウ バ ギセス ジブ ダ'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        var_decl = ast.declarations[0]
        unary_expr = var_decl.initializer
        expect(unary_expr).to be_a(Grongigo::AST::UnaryExpr)
        expect(unary_expr.operator).to eq('-')
        expect(unary_expr.prefix).to be true
      end

      it 'parses assignment expressions' do
        source = <<~GRONGIGO
          パザ バサ デギド バサ ザジレ
            バ ギセス パパン
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        expr_stmt = func.body.statements[0]
        assign_expr = expr_stmt.expression
        expect(assign_expr).to be_a(Grongigo::AST::AssignExpr)
        expect(assign_expr.target).to be_a(Grongigo::AST::Identifier)
        expect(assign_expr.value).to be_a(Grongigo::AST::NumberLiteral)
      end

      it 'parses function call expressions' do
        source = <<~GRONGIGO
          パザ バサ デギド バサ ザジレ
            ジョウジ ザジレジョヂザギ「デギド」ゴパシジョヂザギ
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        expr_stmt = func.body.statements[0]
        call_expr = expr_stmt.expression
        expect(call_expr).to be_a(Grongigo::AST::CallExpr)
        expect(call_expr.callee).to be_a(Grongigo::AST::Identifier)
        expect(call_expr.arguments.length).to eq(1)
      end

      it 'parses array index expressions' do
        source = <<~GRONGIGO
          パザ バサ デギド バサ ザジレ
            バ ギセス ガラズ ザジレパギセヅ ゼゼソ ゴパシザギセヅ
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        expr_stmt = func.body.statements[0]
        assign_expr = expr_stmt.expression
        index_expr = assign_expr.value
        expect(index_expr).to be_a(Grongigo::AST::IndexExpr)
        expect(index_expr.array).to be_a(Grongigo::AST::Identifier)
        expect(index_expr.index).to be_a(Grongigo::AST::NumberLiteral)
      end

      it 'parses comparison expressions' do
        source = 'ゲギグウ セギャスド ギセス バ ジドギギ ダ'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        var_decl = ast.declarations[0]
        binary_expr = var_decl.initializer
        expect(binary_expr).to be_a(Grongigo::AST::BinaryExpr)
        expect(binary_expr.operator).to eq('==')
      end

      it 'parses logical expressions' do
        source = 'ゲギグウ セギャスド ギセス バ バヅ ダ'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        var_decl = ast.declarations[0]
        binary_expr = var_decl.initializer
        expect(binary_expr).to be_a(Grongigo::AST::BinaryExpr)
        expect(binary_expr.operator).to eq('&&')
      end
    end

    context 'with literals' do
      it 'parses number literals' do
        source = 'ゲギグウ バ ギセス パパン'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        var_decl = ast.declarations[0]
        expect(var_decl.initializer).to be_a(Grongigo::AST::NumberLiteral)
        expect(var_decl.initializer.value).to eq(1)
      end

      it 'parses string literals' do
        source = <<~GRONGIGO
          パザ バサ デギド バサ ザジレ
            ジョウジ ザジレジョヂザギ「ゼソ」ゴパシジョヂザギ
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        func = ast.declarations[0]
        expr_stmt = func.body.statements[0]
        call_expr = expr_stmt.expression
        string_lit = call_expr.arguments[0]
        expect(string_lit).to be_a(Grongigo::AST::StringLiteral)
        expect(string_lit.value).to eq('ゼソ')
      end

      it 'parses char literals' do
        source = 'ロジ ダ ギセス 『ガ』'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        var_decl = ast.declarations[0]
        expect(var_decl.initializer).to be_a(Grongigo::AST::CharLiteral)
        expect(var_decl.initializer.value).to eq('ガ')
      end
    end

    context 'with operator precedence' do
      it 'respects multiplication over addition' do
        source = 'ゲギグウ バ ギセス ガ ダグ ダ バゲス ザ'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        var_decl = ast.declarations[0]
        add_expr = var_decl.initializer
        expect(add_expr).to be_a(Grongigo::AST::BinaryExpr)
        expect(add_expr.operator).to eq('+')

        # Right side should be multiplication
        mul_expr = add_expr.right
        expect(mul_expr).to be_a(Grongigo::AST::BinaryExpr)
        expect(mul_expr.operator).to eq('*')
      end

      it 'respects comparison over logical AND' do
        source = 'ゲギグウ バ ギセス ガ ギョウバシ ダ バヅ ザ ザギバシ ゾ'
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        var_decl = ast.declarations[0]
        and_expr = var_decl.initializer
        expect(and_expr).to be_a(Grongigo::AST::BinaryExpr)
        expect(and_expr.operator).to eq('&&')

        # Both sides should be comparisons
        expect(and_expr.left).to be_a(Grongigo::AST::BinaryExpr)
        expect(and_expr.left.operator).to eq('<')
        expect(and_expr.right).to be_a(Grongigo::AST::BinaryExpr)
        expect(and_expr.right.operator).to eq('>')
      end
    end

    context 'with error handling' do
      it 'raises ParseError on invalid syntax' do
        source = 'ゲギグウ ゲギグウ' # Invalid: type followed by type
        tokens = tokenize(source)
        parser = described_class.new(tokens)

        expect { parser.parse }.to raise_error(Grongigo::ParseError)
      end
    end

    context 'with complete programs' do
      it 'parses a simple main function' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO
        tokens = tokenize(source)
        parser = described_class.new(tokens)
        ast = parser.parse

        expect(ast).to be_a(Grongigo::AST::Program)
        expect(ast.declarations.length).to eq(1)

        func = ast.declarations[0]
        expect(func.return_type).to eq('int')
        expect(func.name).to eq('main')
        expect(func.body.statements.length).to eq(1)
        expect(func.body.statements[0]).to be_a(Grongigo::AST::ReturnStmt)
      end
    end
  end
end
