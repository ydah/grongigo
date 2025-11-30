# Grongigo

A programming language compiler using "Grongi language," the language of the Gurongi tribe from Kamen Rider Kuuga (Masked Rider Kuuga).

## Overview

Grongigo is a programming language designed based on the linguistic rules of Grongi language. It has C-like syntax and transpiles source code written in Grongigo to C language.

### Features

- Complete Grongigo syntax: All keywords and operators are written in Grongigo
- Base-9 number system: Follows the Gurongi tribe's counting method using base-9
- Transpile to C: Generated C code can be compiled with gcc

## Grongigo Conversion Rules

Grongigo is a language that converts Japanese consonants according to certain rules:

| Japanese | Grongigo |
|----------|----------|
| ア行 | ガ行 |
| カ行 | バ行 |
| サ行 | ガ行 |
| タ行 | ダ行 |
| ナ行 | バ行 |
| ハ行 | ザ行 |
| マ行 | ラ行 |
| ヤ行 | ジャ行 |
| ラ行 | サ行 |
| ワ | パ |
| ガ行 | ガ行 |
| ザ行 | ザ行 |
| ダ行 | ザ行 |
| バ行 | ダ行 |
| パ行 | マ行 |

Special rules:
- Long vowels (ー) repeat the previous sound
- Geminate consonants (っ) repeat the following sound
- Particles: "ga" → "gu", "no" → "n", "ha" → "pa", "wo" → "zo"

## Language Specification

### Type Keywords

| Grongigo | C | Japanese Origin |
|----------|---|----------------|
| ゲギグウ | int | 整数 (seisuu - integer) |
| ロジ | char | 文字 (moji - character) |
| ズゾウ | float | 浮動 (fudou - floating) |
| バサ | void | 空 (kara - empty) |

### Control Structures

| Grongigo | C | Japanese Origin |
|----------|---|----------------|
| ジョウベン | if | 条件 (jouken - condition) |
| ゾバ | else | 他 (hoka - other) |
| ガギザ | while | 間 (aida - interval) |
| ブシバゲギ | for | 繰返し (kurikaeshi - repeat) |
| ロゾス | return | 戻す (modosu - return) |
| ブゲス | break | 抜ける (nukeru - exit) |
| ヅヅゲス | continue | 続ける (tsuzukeru - continue) |
| ゲンダブ | switch | 選択 (sentaku - selection) |
| ダガギ | case | 場合 (baai - case) |
| ビデギ | default | 既定 (kitei - default) |

### Operators

| Grongigo | C | Japanese Origin |
|----------|---|----------------|
| ダグ | + | 足す (tasu - add) |
| ジブ | - | 引く (hiku - subtract) |
| バゲス | * | 掛ける (kakeru - multiply) |
| パス | / | 割る (waru - divide) |
| ガラシ | % | 余り (amari - remainder) |
| ギセス | = | 入れる (ireru - assign) |
| ジドギギ | == | 等しい (hitoshii - equal) |
| ジドギグバギ | != | 等しくない (not equal) |
| ギョウバシ | < | 小なり (shounari - less than) |
| ザギバシ | > | 大なり (dainari - greater than) |
| ギバ | <= | 以下 (ika - less or equal) |
| ギジョウ | >= | 以上 (ijou - greater or equal) |
| バヅ | && | かつ (katsu - and) |
| ラダパ | \|\| | または (mataha - or) |
| ジデギ | ! | 否定 (hitei - negation) |

### Numbers (Base-9)

The Gurongi tribe uses base-9, with numbers based on English numerals converted to Grongigo:

| Decimal | Base-9 | Grongigo | Origin |
|---------|--------|----------|--------|
| 0 | 0 | ゼゼソ | zero |
| 1 | 1 | パパン | one (wan) |
| 2 | 2 | ドググ | two |
| 3 | 3 | グシギ | three |
| 4 | 4 | ズゴゴ | four |
| 5 | 5 | ズガギ | five |
| 6 | 6 | ギブグ | six |
| 7 | 7 | ゲズン | seven |
| 8 | 8 | ゲギド | eight |
| 9 | 10 | バギン | nine |

Compound number representation:
- Addition: ド (Example: バギンドパパン = 9 + 1 = 10)
- Multiplication: グ (Example: バギングバギン = 9 × 9 = 81)

### Syntax Elements

| Grongigo | Meaning |
|----------|---------|
| ザジレ ... ゴパシ | Block { ... } |
| パザ | Function definition marker |
| ゴロ | main function name |
| ジョウジ | printf |
| 「...」 | String literal |
| 『...』 | Character literal |
| （ ） | Parentheses |
| 、 | Comma |
| 。 | Semicolon (optional) |
| ゴゴ ... | Line comment |
| ゴビ ... ビゴ | Block comment |

## Usage

### Installation

```bash
git clone <repository>
cd grongigo
```

### Compilation

```bash
# Convert Grongigo source to C
bin/grongigo examples/hello.grg

# Specify output file
bin/grongigo -o output.c examples/hello.grg

# Compile and run (requires gcc)
bin/grongigo -r examples/fizzbuzz.grg
```

### Options

```
-o, --output FILE    Specify output file name
-v, --verbose        Verbose output
-t, --tokens         Display token list
-a, --ast            Display abstract syntax tree
-r, --run            Run after compilation (requires gcc)
-c, --convert TEXT   Convert Japanese text to Grongigo
-n, --number NUM     Convert decimal number to base-9 Grongigo number
-h, --help           Show help
```

### Japanese Conversion Utility

```bash
# Convert Japanese to Grongigo
bin/grongigo -c "こんにちは"
# Output: ボンビヂザ

# Convert number to base-9 Grongigo
bin/grongigo -n 100
# Output: 100 (decimal) = バギングバギンドバギングパパンドパパン (Grongigo)
```

## Sample Programs

### Hello World

```
パザ ゲギグウ ゴロ バサ
ザジレ
    ジョウジ（「リントンボドバゼ\n」）
    ロゾス ゼゼソ
ゴパシ
```

### FizzBuzz

```
パザ ゲギグウ ゴロ バサ
ザジレ
    ゲギグウ ギ ギセス パパン

    ガギザ ギ ギバ バギングバギン
    ザジレ
        ジョウベン ギ ガラシ バギンドギブグ ジドギギ ゼゼソ
        ザジレ
            ジョウジ（「FizzBuzz\n」）
        ゴパシ
        ゾバ ジョウベン ギ ガラシ グシギ ジドギギ ゼゼソ
        ザジレ
            ジョウジ（「Fizz\n」）
        ゴパシ
        ゾバ ジョウベン ギ ガラシ ズガギ ジドギギ ゼゼソ
        ザジレ
            ジョウジ（「Buzz\n」）
        ゴパシ
        ゾバ
        ザジレ
            ジョウジ（「%d\n」、 ギ）
        ゴパシ

        ギ ギセス ギ ダグ パパン
    ゴパシ

    ロゾス ゼゼソ
ゴパシ
```

## Proper Nouns (Untranslated Words)

The following are unique Grongigo expressions that are not converted:

- クウガ (Kuuga): Ancient warrior adversary
- リント (Linto): Humans (hunting targets)
- ゲゲル (Gegeru): Murder game
- グロンギ (Gurongi): Tribe name
- グセパ (Gusepa): Bracelet that records Gegeru victims
- バグンダダ (Bagundada): Counter (abacus-like tool)

## File Structure

```
grongigo/
├── bin/
│   └── grongigo          # CLI executable
├── lib/
│   ├── grongigo.rb       # Main module
│   └── grongigo/
│       ├── constants.rb  # Constant definitions
│       ├── token.rb      # Token class
│       ├── lexer.rb      # Lexical analyzer
│       ├── parser.rb     # Parser
│       ├── codegen.rb    # Code generator
│       ├── compiler.rb   # Main compiler
│       ├── jp2grg.rb     # Japanese to Grongigo converter
│       ├── parse_error.rb # Parse error class
│       └── ast/          # AST node classes
├── examples/
│   ├── hello.grg         # Hello World
│   ├── calc.grg          # Calculation sample
│   ├── fizzbuzz.grg      # FizzBuzz
│   └── factorial.grg     # Factorial calculation
├── spec/                 # Test files
└── README.md
```

## License

MIT License

## Acknowledgments

Thanks to the production staff of "Kamen Rider Kuuga (Masked Rider Kuuga)" and all the fans who have decoded and researched Grongi language.

---

*"リントンボドバゼ ザバゲデ グロンギゴゾ ダボギレ！"*
(Speak in Linto's words, enjoy Grongigo!)
