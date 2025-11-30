# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Grongigo::Lexer do
  describe '#tokenize' do
    context 'with keywords' do
      it 'tokenizes type keywords correctly' do
        lexer = described_class.new('ゲギグウ バサ')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:type_keyword)
        expect(tokens[0].value).to eq('int')
        expect(tokens[1].type).to eq(:type_keyword)
        expect(tokens[1].value).to eq('void')
      end

      it 'tokenizes control keywords correctly' do
        lexer = described_class.new('ジョウベン ゾバ ガギザ')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:control_keyword)
        expect(tokens[0].value).to eq('if')
        expect(tokens[1].type).to eq(:control_keyword)
        expect(tokens[1].value).to eq('else')
        expect(tokens[2].type).to eq(:control_keyword)
        expect(tokens[2].value).to eq('while')
      end

      it 'tokenizes other keywords correctly' do
        lexer = described_class.new('ゴロ パザ')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:other_keyword)
        expect(tokens[0].value).to eq('main')
        expect(tokens[1].type).to eq(:other_keyword)
        expect(tokens[1].value).to eq('パザ')
      end
    end

    context 'with operators' do
      it 'tokenizes arithmetic operators' do
        lexer = described_class.new('ダグ ジブ バゲス パス ガラシ')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:operator)
        expect(tokens[0].value).to eq('+')
        expect(tokens[1].type).to eq(:operator)
        expect(tokens[1].value).to eq('-')
        expect(tokens[2].type).to eq(:operator)
        expect(tokens[2].value).to eq('*')
        expect(tokens[3].type).to eq(:operator)
        expect(tokens[3].value).to eq('/')
        expect(tokens[4].type).to eq(:operator)
        expect(tokens[4].value).to eq('%')
      end

      it 'tokenizes comparison operators' do
        lexer = described_class.new('ジドギギ ジドギグバギ ギョウバシ ザギバシ')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:operator)
        expect(tokens[0].value).to eq('==')
        expect(tokens[1].type).to eq(:operator)
        expect(tokens[1].value).to eq('!=')
        expect(tokens[2].type).to eq(:operator)
        expect(tokens[2].value).to eq('<')
        expect(tokens[3].type).to eq(:operator)
        expect(tokens[3].value).to eq('>')
      end

      it 'tokenizes assignment operator' do
        lexer = described_class.new('ギセス')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:operator)
        expect(tokens[0].value).to eq('=')
      end

      it 'tokenizes logical operators' do
        lexer = described_class.new('バヅ ラダパ ジデギ')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:operator)
        expect(tokens[0].value).to eq('&&')
        expect(tokens[1].type).to eq(:operator)
        expect(tokens[1].value).to eq('||')
        expect(tokens[2].type).to eq(:operator)
        expect(tokens[2].value).to eq('!')
      end

      it 'tokenizes increment/decrement operators' do
        lexer = described_class.new('ダグダグ ジブジブ')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:operator)
        expect(tokens[0].value).to eq('++')
        expect(tokens[1].type).to eq(:operator)
        expect(tokens[1].value).to eq('--')
      end
    end

    context 'with literals' do
      it 'tokenizes string literals' do
        lexer = described_class.new('「ゾレソパ」')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:string_literal)
        expect(tokens[0].value).to eq('ゾレソパ')
      end

      it 'tokenizes char literals' do
        lexer = described_class.new('『ガ』')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:char_literal)
        expect(tokens[0].value).to eq('ガ')
      end

      it 'tokenizes decimal numbers' do
        lexer = described_class.new('123 456')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:number)
        expect(tokens[0].value).to eq(123)
        expect(tokens[1].type).to eq(:number)
        expect(tokens[1].value).to eq(456)
      end

      it 'tokenizes grongigo numbers' do
        lexer = described_class.new('ゼゼソ パパン ドググ')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:number)
        expect(tokens[0].value).to eq(0)
        expect(tokens[1].type).to eq(:number)
        expect(tokens[1].value).to eq(1)
        expect(tokens[2].type).to eq(:number)
        expect(tokens[2].value).to eq(2)
      end

      it 'tokenizes compound grongigo numbers' do
        lexer = described_class.new('バギンドパパン')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:number)
        expect(tokens[0].value).to eq(10) # 9 + 1
      end
    end

    context 'with identifiers' do
      it 'tokenizes ASCII identifiers' do
        lexer = described_class.new('foo bar_baz')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:identifier)
        expect(tokens[0].value).to eq('foo')
        expect(tokens[1].type).to eq(:identifier)
        expect(tokens[1].value).to eq('bar_baz')
      end

      it 'tokenizes katakana identifiers' do
        lexer = described_class.new('ヘンスウ')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:identifier)
        expect(tokens[0].value).to eq('ヘンスウ')
      end
    end

    context 'with punctuation' do
      it 'tokenizes braces' do
        lexer = described_class.new('ザジレ ゴパシ')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:open_brace)
        expect(tokens[0].value).to eq('{')
        expect(tokens[1].type).to eq(:close_brace)
        expect(tokens[1].value).to eq('}')
      end

      it 'tokenizes parentheses' do
        lexer = described_class.new('（）')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:open_paren)
        expect(tokens[0].value).to eq('(')
        expect(tokens[1].type).to eq(:close_paren)
        expect(tokens[1].value).to eq(')')
      end

      it 'tokenizes ASCII parentheses' do
        lexer = described_class.new('()')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:open_paren)
        expect(tokens[1].type).to eq(:close_paren)
      end

      it 'tokenizes brackets' do
        lexer = described_class.new('［］')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:open_bracket)
        expect(tokens[0].value).to eq('[')
        expect(tokens[1].type).to eq(:close_bracket)
        expect(tokens[1].value).to eq(']')
      end

      it 'tokenizes comma' do
        lexer = described_class.new('、')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:comma)
        expect(tokens[0].value).to eq(',')
      end

      it 'tokenizes semicolon' do
        lexer = described_class.new('。')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:semicolon)
        expect(tokens[0].value).to eq(';')
      end

      it 'tokenizes colon' do
        lexer = described_class.new('：')
        tokens = lexer.tokenize

        expect(tokens[0].type).to eq(:colon)
        expect(tokens[0].value).to eq(':')
      end
    end

    context 'with comments' do
      it 'skips line comments' do
        lexer = described_class.new("ゲギグウ ゴゴ これはコメント\nバサ")
        tokens = lexer.tokenize

        expect(tokens.length).to eq(3) # type_keyword, type_keyword, eof
        expect(tokens[0].type).to eq(:type_keyword)
        expect(tokens[0].value).to eq('int')
        expect(tokens[1].type).to eq(:type_keyword)
        expect(tokens[1].value).to eq('void')
      end

      it 'skips block comments' do
        lexer = described_class.new('ゲギグウ ゴビ コメント ビゴ バサ')
        tokens = lexer.tokenize

        expect(tokens.length).to eq(3) # type_keyword, type_keyword, eof
        expect(tokens[0].value).to eq('int')
        expect(tokens[1].value).to eq('void')
      end
    end

    context 'with complete programs' do
      it 'tokenizes a simple function declaration' do
        source = <<~GRONGIGO
          パザ ゲギグウ ゴロ バサ ザジレ
            ロゾス ゼゼソ
          ゴパシ
        GRONGIGO

        lexer = described_class.new(source)
        tokens = lexer.tokenize

        expect(tokens[0].value).to eq('パザ') # パザ
        expect(tokens[1].value).to eq('int') # ゲギグウ
        expect(tokens[2].value).to eq('main') # ゴロ
        expect(tokens[3].value).to eq('void') # バサ
        expect(tokens[4].type).to eq(:open_brace)
        expect(tokens[5].value).to eq('return') # ロゾス
        expect(tokens[6].type).to eq(:number)
        expect(tokens[6].value).to eq(0)
        expect(tokens[7].type).to eq(:close_brace)
      end
    end

    context 'with line and column tracking' do
      it 'tracks line numbers correctly' do
        source = "ゲギグウ\nバサ"
        lexer = described_class.new(source)
        tokens = lexer.tokenize

        expect(tokens[0].line).to eq(1)
        expect(tokens[1].line).to eq(2)
      end

      it 'tracks column numbers correctly' do
        lexer = described_class.new('ゲギグウ バサ')
        tokens = lexer.tokenize

        expect(tokens[0].column).to eq(1)
        expect(tokens[1].column).to be > 1
      end
    end

    context 'with edge cases' do
      it 'tokenizes empty source' do
        lexer = described_class.new('')
        tokens = lexer.tokenize

        expect(tokens.length).to eq(1)
        expect(tokens[0].type).to eq(:eof)
      end

      it 'handles whitespace-only source' do
        lexer = described_class.new("   \n  \t  ")
        tokens = lexer.tokenize

        expect(tokens.length).to eq(1)
        expect(tokens[0].type).to eq(:eof)
      end
    end
  end
end
