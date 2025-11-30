# frozen_string_literal: true

module Grongigo
  # Utility: Convert Japanese to Grongigo
  class Jp2Grg
    CONVERSION_TABLE = {
      # Seion (unvoiced)
      'あ' => 'ガ', 'い' => 'ギ', 'う' => 'グ', 'え' => 'ゲ', 'お' => 'ゴ',
      'か' => 'バ', 'き' => 'ビ', 'く' => 'ブ', 'け' => 'ベ', 'こ' => 'ボ',
      'さ' => 'ガ', 'し' => 'ギ', 'す' => 'グ', 'せ' => 'ゲ', 'そ' => 'ゴ',
      'た' => 'ダ', 'ち' => 'ヂ', 'つ' => 'ヅ', 'て' => 'デ', 'と' => 'ド',
      'な' => 'バ', 'に' => 'ビ', 'ぬ' => 'ブ', 'ね' => 'ベ', 'の' => 'ボ',
      'は' => 'ザ', 'ひ' => 'ジ', 'ふ' => 'ズ', 'へ' => 'ゼ', 'ほ' => 'ゾ',
      'ま' => 'ラ', 'み' => 'リ', 'む' => 'ル', 'め' => 'レ', 'も' => 'ロ',
      'や' => 'ジャ', 'ゆ' => 'ジュ', 'よ' => 'ジョ',
      'ら' => 'サ', 'り' => 'シ', 'る' => 'ス', 'れ' => 'セ', 'ろ' => 'ソ',
      'わ' => 'パ', 'を' => 'ゾ', 'ん' => 'ン',
      # Dakuon (voiced)
      'が' => 'ガ', 'ぎ' => 'ギ', 'ぐ' => 'グ', 'げ' => 'ゲ', 'ご' => 'ゴ',
      'ざ' => 'ザ', 'じ' => 'ジ', 'ず' => 'ズ', 'ぜ' => 'ゼ', 'ぞ' => 'ゾ',
      'だ' => 'ザ', 'ぢ' => 'ジ', 'づ' => 'ズ', 'で' => 'ゼ', 'ど' => 'ゾ',
      'ば' => 'ダ', 'び' => 'ヂ', 'ぶ' => 'ヅ', 'べ' => 'デ', 'ぼ' => 'ド',
      'ぱ' => 'マ', 'ぴ' => 'ミ', 'ぷ' => 'ム', 'ぺ' => 'メ', 'ぽ' => 'モ',
      # Small letters
      'ぁ' => 'ァ', 'ぃ' => 'ィ', 'ぅ' => 'ゥ', 'ぇ' => 'ェ', 'ぉ' => 'ォ',
      'ゃ' => 'ャ', 'ゅ' => 'ュ', 'ょ' => 'ョ',
      'っ' => 'ッ',
      # Katakana (direct conversion)
      'ア' => 'ガ', 'イ' => 'ギ', 'ウ' => 'グ', 'エ' => 'ゲ', 'オ' => 'ゴ',
      'カ' => 'バ', 'キ' => 'ビ', 'ク' => 'ブ', 'ケ' => 'ベ', 'コ' => 'ボ',
      'サ' => 'ガ', 'シ' => 'ギ', 'ス' => 'グ', 'セ' => 'ゲ', 'ソ' => 'ゴ',
      'タ' => 'ダ', 'チ' => 'ヂ', 'ツ' => 'ヅ', 'テ' => 'デ', 'ト' => 'ド',
      'ナ' => 'バ', 'ニ' => 'ビ', 'ヌ' => 'ブ', 'ネ' => 'ベ', 'ノ' => 'ボ',
      'ハ' => 'ザ', 'ヒ' => 'ジ', 'フ' => 'ズ', 'ヘ' => 'ゼ', 'ホ' => 'ゾ',
      'マ' => 'ラ', 'ミ' => 'リ', 'ム' => 'ル', 'メ' => 'レ', 'モ' => 'ロ',
      'ヤ' => 'ジャ', 'ユ' => 'ジュ', 'ヨ' => 'ジョ',
      'ラ' => 'サ', 'リ' => 'シ', 'ル' => 'ス', 'レ' => 'セ', 'ロ' => 'ソ',
      'ワ' => 'パ', 'ヲ' => 'ゾ', 'ン' => 'ン',
      'ガ' => 'ガ', 'ギ' => 'ギ', 'グ' => 'グ', 'ゲ' => 'ゲ', 'ゴ' => 'ゴ',
      'ザ' => 'ザ', 'ジ' => 'ジ', 'ズ' => 'ズ', 'ゼ' => 'ゼ', 'ゾ' => 'ゾ',
      'ダ' => 'ザ', 'ヂ' => 'ジ', 'ヅ' => 'ズ', 'デ' => 'ゼ', 'ド' => 'ゾ',
      'バ' => 'ダ', 'ビ' => 'ヂ', 'ブ' => 'ヅ', 'ベ' => 'デ', 'ボ' => 'ド',
      'パ' => 'マ', 'ピ' => 'ミ', 'プ' => 'ム', 'ペ' => 'メ', 'ポ' => 'モ'
    }.freeze

    def self.convert(text)
      result = ''
      chars = text.chars
      i = 0

      while i < chars.length
        # Check if current position starts with a proper noun
        matched_noun = nil
        PROPER_NOUNS.each do |noun|
          if text[i, noun.length] == noun
            matched_noun = noun
            break
          end
        end

        if matched_noun
          # Skip proper nouns (don't convert)
          result += matched_noun
          i += matched_noun.length
        else
          char = chars[i]
          result += if CONVERSION_TABLE.key?(char)
                      CONVERSION_TABLE[char]
                    else
                      char
                    end
          i += 1
        end
      end

      result
    end

    # Convert decimal to base-9 Grongigo number
    def self.num2grg(num)
      return 'ゼゼソ' if num == 0

      digits = %w[ゼゼソ パパン ドググ グシギ ズゴゴ ズガギ ギブグ ゲズン ゲギド]

      # Convert to base-9
      base9_digits = []
      n = num
      while n > 0
        base9_digits.unshift(n % 9)
        n /= 9
      end

      # Convert to Grongigo representation
      return digits[base9_digits[0]] if base9_digits.length == 1

      # Multiple digits case
      result_parts = []
      base9_digits.reverse.each_with_index do |digit, power|
        next if digit == 0

        if power == 0
          result_parts.unshift(digits[digit])
        else
          # バギン (9) to the power × digit
          multiplier = 'バギン' + ('グバギン' * (power - 1))
          if digit == 1
            result_parts.unshift(multiplier)
          else
            result_parts.unshift("#{multiplier}グ#{digits[digit]}")
          end
        end
      end

      result_parts.join('ド')
    end
  end
end
