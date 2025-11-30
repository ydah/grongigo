# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Grongigo::CodeGenerator do
  def parse(source)
    tokens = Grongigo::Lexer.new(source).tokenize
    Grongigo::Parser.new(tokens).parse
  end

  describe '#generate' do
    context 'with function declarations' do
      it 'generates a simple main function' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('#include <stdio.h>')
        expect(c_code).to include('#include <stdlib.h>')
        expect(c_code).to include('int main(void)')
        expect(c_code).to include('return 0;')
      end

      it 'generates a function with parameters' do
        source = 'パザ ゲギグウ add ゲギグウ x、ゲギグウ y ザジレ ロゾス x ダグ y ゴパシ'
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int add(int x, int y)')
        expect(c_code).to include('return (x + y);')
      end

      it 'generates a void function' do
        source = 'パザ バサ test バサ ザジレ ゴパシ'
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('void test()')
      end
    end

    context 'with variable declarations' do
      it 'generates a simple variable declaration' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ x
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int x;')
      end

      it 'generates a variable declaration with initializer' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ x ギセス パパン
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int x = 1;')
      end

      it 'generates multiple variable declarations' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ x
            ゲギグウ y ギセス ドググ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int x;')
        expect(c_code).to include('int y = 2;')
      end
    end

    context 'with control flow statements' do
      it 'generates if statement' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ジョウベン x ザジレ
              ロゾス
            ゴパシ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('if (x)')
        expect(c_code).to match(/if.*\{.*return.*\}/m)
      end

      it 'generates if-else statement' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ジョウベン x ザジレ
              ロゾス パパン
            ゴパシ ゾバ ザジレ
              ロゾス ゼゼソ
            ゴパシ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('if (x)')
        expect(c_code).to include('else')
        expect(c_code).to include('return 1;')
        expect(c_code).to include('return 0;')
      end

      it 'generates while loop' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ガギザ x ギョウバシ バギン ザジレ
              x ダグダグ
            ゴパシ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('while ((x < 9))')
        expect(c_code).to include('x++;')
      end

      it 'generates for loop' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ブシバゲギ (ゲギグウ i ギセス ゼゼソ、i ギョウバシ バギン、i ダグダグ) ザジレ
              printf(「test」)
            ゴパシ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('for (int i = 0; (i < 9); i++)')
        expect(c_code).to include('printf("test");')
      end
    end

    context 'with expressions' do
      it 'generates binary expressions' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ result ギセス x ダグ y
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int result = (x + y);')
      end

      it 'generates unary expressions' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ x ギセス ジブ y
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int x = -y;')
      end

      it 'generates assignment expressions' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            x ギセス パパン
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('x = 1;')
      end

      it 'generates function call expressions' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            printf(「Hello」、x)
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('printf("Hello", x);')
      end

      it 'generates array access expressions' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ x ギセス arr[ゼゼソ]
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int x = arr[0];')
      end

      it 'generates comparison expressions' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ result ギセス x ジドギギ y
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int result = (x == y);')
      end

      it 'generates logical expressions' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ result ギセス x バヅ y
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int result = (x && y);')
      end
    end

    context 'with literals' do
      it 'generates number literals' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ x ギセス パパン
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int x = 1;')
      end

      it 'generates string literals' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            printf(「Hello, World!」)
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('printf("Hello, World!");')
      end

      it 'escapes special characters in strings' do
        source = <<~GRONGIGO
                    パザ バサ test バサ ザジレ
                      printf(「Line1
          Line2」)
                    ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('\\n')
      end

      it 'generates char literals' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ロジ c ギセス 『a』
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include("char c = 'a';")
      end
    end

    context 'with katakana identifier conversion' do
      it 'converts katakana identifiers to romaji' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ カウンタ ギセス ゼゼソ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        # Should convert カウンタ to romaji
        expect(c_code).to match(/int \w+ = 0;/)
      end

      it 'preserves ASCII identifiers' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ゲギグウ counter ギセス ゼゼソ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int counter = 0;')
      end

      it 'preserves standard C function names' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            printf(「test」)
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('printf')
        expect(c_code).to include('main')
      end
    end

    context 'with complex programs' do
      it 'generates a complete program with multiple functions' do
        source = <<~GRONGIGO
          パザ ゲギグウ add ゲギグウ a、ゲギグウ b ザジレ
            ロゾス a ダグ b
          ゴパシ

          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ result ギセス add(グシギ、ズゴゴ)
            printf(「Result: %d」、result)
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('int add(int a, int b)')
        expect(c_code).to include('return (a + b);')
        expect(c_code).to include('int main(void)')
        expect(c_code).to include('int result = add(3, 4);')
        expect(c_code).to include('printf("Result: %d", result);')
      end

      it 'generates proper indentation' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ジョウベン パパン ザジレ
              printf(「nested」)
            ゴパシ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        # Check that nested blocks are properly indented
        expect(c_code).to match(/^\s{4}if/)
        expect(c_code).to match(/^\s{8}printf/)
      end
    end

    context 'with edge cases' do
      it 'generates code for empty function body' do
        source = 'パザ バサ test バサ ザジレ ゴパシ'
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('void test()')
        expect(c_code).to include('{')
        expect(c_code).to include('}')
      end

      it 'handles nested blocks' do
        source = <<~GRONGIGO
          パザ バサ test バサ ザジレ
            ザジレ
              ザジレ
                printf(「deep」)
              ゴパシ
            ゴパシ
          ゴパシ
        GRONGIGO
        ast = parse(source)
        generator = described_class.new
        c_code = generator.generate(ast)

        expect(c_code).to include('printf("deep");')
        expect(c_code.scan('{').length).to eq(c_code.scan('}').length)
      end
    end
  end
end
