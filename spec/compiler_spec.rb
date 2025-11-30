# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'fileutils'

RSpec.describe Grongigo::Compiler do
  describe '#compile' do
    context 'with simple programs' do
      it 'compiles a minimal main function' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).not_to be_nil
        expect(c_code).to include('#include <stdio.h>')
        expect(c_code).to include('int main(void)')
        expect(c_code).to include('return 0;')
        expect(compiler.errors).to be_empty
      end

      it 'compiles a function with printf' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            printf(「Hello, World!」)
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('printf("Hello, World!");')
        expect(compiler.errors).to be_empty
      end

      it 'compiles variable declarations' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ x ギセス パパン
            ゲギグウ y ギセス ドググ
            ゲギグウ sum ギセス x ダグ y
            ロゾス sum
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('int x = 1;')
        expect(c_code).to include('int y = 2;')
        expect(c_code).to include('int sum = (x + y);')
        expect(compiler.errors).to be_empty
      end
    end

    context 'with control structures' do
      it 'compiles if-else statements' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ x ギセス パパン
            ジョウベン x ザジレ
              printf(「x is true」)
            ゴパシ ゾバ ザジレ
              printf(「x is false」)
            ゴパシ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('if (x)')
        expect(c_code).to include('else')
        expect(compiler.errors).to be_empty
      end

      it 'compiles while loops' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ i ギセス ゼゼソ
            ガギザ i ギョウバシ バギン ザジレ
              i ダグダグ
            ゴパシ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('while ((i < 9))')
        expect(c_code).to include('i++;')
        expect(compiler.errors).to be_empty
      end

      it 'compiles for loops' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ブシバゲギ (ゲギグウ i ギセス ゼゼソ、i ギョウバシ バギン、i ダグダグ) ザジレ
              printf(「%d」、i)
            ゴパシ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('for (int i = 0; (i < 9); i++)')
        expect(compiler.errors).to be_empty
      end
    end

    context 'with multiple functions' do
      it 'compiles multiple function definitions' do
        source = <<~GRONGIGO
          パザ ゲギグウ add ゲギグウ a、ゲギグウ b ザジレ
            ロゾス a ダグ b
          ゴパシ

          パザ ゲギグウ multiply ゲギグウ a、ゲギグウ b ザジレ
            ロゾス a バゲス b
          ゴパシ

          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ result1 ギセス add(グシギ、ズゴゴ)
            ゲギグウ result2 ギセス multiply(ドググ、グシギ)
            printf(「%d %d」、result1、result2)
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('int add(int a, int b)')
        expect(c_code).to include('int multiply(int a, int b)')
        expect(c_code).to include('int main(void)')
        expect(compiler.errors).to be_empty
      end
    end

    context 'with expressions' do
      it 'compiles arithmetic expressions' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ a ギセス パパン ダグ ドググ バゲス グシギ
            ロゾス a
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('int a = (1 + (2 * 3));')
        expect(compiler.errors).to be_empty
      end

      it 'compiles comparison expressions' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ x ギセス パパン
            ジョウベン x ジドギギ パパン ザジレ
              printf(「equal」)
            ゴパシ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('if ((x == 1))')
        expect(compiler.errors).to be_empty
      end

      it 'compiles logical expressions' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ x ギセス パパン
            ゲギグウ y ギセス ドググ
            ジョウベン x ザギバシ ゼゼソ バヅ y ギョウバシ ゼゼソ ザジレ
              printf(「both true」)
            ゴパシ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('&&')
        expect(compiler.errors).to be_empty
      end
    end

    context 'with verbose output' do
      it 'outputs tokens when output_tokens is true' do
        source = 'パザ ゲギグウ ゴロ バサ ザジレ ロゾス ゼゼソ ゴパシ'
        compiler = described_class.new(output_tokens: true)

        expect { compiler.compile(source) }.to output(/Token/).to_stdout
      end

      it 'outputs AST when output_ast is true' do
        source = 'パザ ゲギグウ ゴロ バサ ザジレ ロゾス ゼゼソ ゴパシ'
        compiler = described_class.new(output_ast: true)

        expect { compiler.compile(source) }.to output(/Program/).to_stdout
      end

      it 'outputs log messages when verbose is true' do
        source = 'パザ ゲギグウ ゴロ バサ ザジレ ロゾス ゼゼソ ゴパシ'
        compiler = described_class.new(verbose: true)

        expect { compiler.compile(source) }.to output(/Grongigo/).to_stdout
      end
    end

    context 'with error handling' do
      it 'returns nil on parse error' do
        source = 'ゲギグウ ゲギグウ' # Invalid syntax
        compiler = described_class.new

        c_code = compiler.compile(source)

        expect(c_code).to be_nil
        expect(compiler.errors).not_to be_empty
      end

      it 'captures parse errors' do
        source = 'パザ ゲギグウ' # Incomplete function
        compiler = described_class.new

        compiler.compile(source)

        expect(compiler.errors.length).to be > 0
        expect(compiler.errors.first).to include('error')
      end
    end

    context 'with file compilation' do
      let(:temp_dir) { Dir.mktmpdir }
      let(:input_file) { File.join(temp_dir, 'test.gro') }
      let(:output_file) { File.join(temp_dir, 'test.c') }

      after do
        FileUtils.rm_rf(temp_dir)
      end

      it 'compiles a file successfully' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        File.write(input_file, source)
        compiler = described_class.new

        result = compiler.compile_file(input_file, output_file)

        expect(result).to be true
        expect(File.exist?(output_file)).to be true
        c_code = File.read(output_file)
        expect(c_code).to include('int main(void)')
      end

      it 'returns false on compilation error' do
        source = 'ゲギグウ ゲギグウ' # Invalid
        File.write(input_file, source)
        compiler = described_class.new

        result = compiler.compile_file(input_file, output_file)

        expect(result).to be false
        expect(compiler.errors).not_to be_empty
      end

      it 'uses default output path when not specified' do
        source = 'パザ ゲギグウ ゴロ バサ ザジレ ロゾス ゼゼソ ゴパシ'
        File.write(input_file, source)
        compiler = described_class.new

        compiler.compile_file(input_file)

        default_output = input_file.sub(/\.gro$/, '.c')
        expect(File.exist?(default_output)).to be true
        FileUtils.rm(default_output)
      end
    end

    context 'with complete real-world programs' do
      it 'compiles a fibonacci function' do
        source = <<~GRONGIGO
          パザ ゲギグウ fib ゲギグウ n ザジレ
            ジョウベン n ギバ パパン ザジレ
              ロゾス n
            ゴパシ
            ロゾス fib(n ジブ パパン) ダグ fib(n ジブ ドググ)
          ゴパシ

          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ result ギセス fib(バギン)
            printf(「Fib(9) = %d」、result)
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('int fib(int n)')
        expect(c_code).to include('if ((n <= 1))')
        expect(c_code).to include('fib((n - 1))')
        expect(c_code).to include('fib((n - 2))')
        expect(compiler.errors).to be_empty
      end

      it 'compiles a factorial function' do
        source = <<~GRONGIGO
          パザ ゲギグウ factorial ゲギグウ n ザジレ
            ジョウベン n ギバ パパン ザジレ
              ロゾス パパン
            ゴパシ
            ロゾス n バゲス factorial(n ジブ パパン)
          ゴパシ

          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ result ギセス factorial(ズガギ)
            printf(「5! = %d」、result)
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('int factorial(int n)')
        expect(c_code).to include('factorial((n - 1))')
        expect(compiler.errors).to be_empty
      end

      it 'compiles a program with loops and conditions' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ゲギグウ sum ギセス ゼゼソ
            ブシバゲギ (ゲギグウ i ギセス パパン、i ギバ バギン、i ダグダグ) ザジレ
              ジョウベン i ガラシ ドググ ジドギギ ゼゼソ ザジレ
                sum ギセス sum ダグ i
              ゴパシ
            ゴパシ
            printf(「Sum: %d」、sum)
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        compiler = described_class.new
        c_code = compiler.compile(source)

        expect(c_code).to include('for (int i = 1; (i <= 9); i++)')
        expect(c_code).to include('if (((i % 2) == 0))')
        expect(c_code).to include('sum = (sum + i);')
        expect(compiler.errors).to be_empty
      end
    end
  end
end
