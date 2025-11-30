# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Grongigo::Jp2Grg do
  describe '.convert' do
    context 'with basic hiragana' do
      it 'converts a-row correctly' do
        expect(described_class.convert('あいうえお')).to eq('ガギグゲゴ')
      end

      it 'converts ka-row correctly' do
        expect(described_class.convert('かきくけこ')).to eq('バビブベボ')
      end

      it 'converts sa-row correctly' do
        expect(described_class.convert('さしすせそ')).to eq('ガギグゲゴ')
      end

      it 'converts ta-row correctly' do
        expect(described_class.convert('たちつてと')).to eq('ダヂヅデド')
      end

      it 'converts na-row correctly' do
        expect(described_class.convert('なにぬねの')).to eq('バビブベボ')
      end

      it 'converts ha-row correctly' do
        expect(described_class.convert('はひふへほ')).to eq('ザジズゼゾ')
      end

      it 'converts ma-row correctly' do
        expect(described_class.convert('まみむめも')).to eq('ラリルレロ')
      end

      it 'converts ya-row correctly' do
        expect(described_class.convert('やゆよ')).to eq('ジャジュジョ')
      end

      it 'converts ra-row correctly' do
        expect(described_class.convert('らりるれろ')).to eq('サシスセソ')
      end

      it 'converts wa correctly' do
        expect(described_class.convert('わを')).to eq('パゾ')
      end

      it 'converts n correctly' do
        expect(described_class.convert('ん')).to eq('ン')
      end
    end

    context 'with dakuten (濁音)' do
      it 'converts ga-row correctly' do
        expect(described_class.convert('がぎぐげご')).to eq('ガギグゲゴ')
      end

      it 'converts za-row correctly' do
        expect(described_class.convert('ざじずぜぞ')).to eq('ザジズゼゾ')
      end

      it 'converts da-row correctly' do
        expect(described_class.convert('だぢづでど')).to eq('ザジズゼゾ')
      end

      it 'converts ba-row correctly' do
        expect(described_class.convert('ばびぶべぼ')).to eq('ダヂヅデド')
      end

      it 'converts pa-row correctly' do
        expect(described_class.convert('ぱぴぷぺぽ')).to eq('マミムメモ')
      end
    end

    context 'with katakana' do
      it 'converts basic katakana correctly' do
        expect(described_class.convert('アイウエオ')).to eq('ガギグゲゴ')
        expect(described_class.convert('カキクケコ')).to eq('バビブベボ')
      end

      it 'converts katakana with dakuten' do
        expect(described_class.convert('ガギグゲゴ')).to eq('ガギグゲゴ')
        expect(described_class.convert('バビブベボ')).to eq('ダヂヅデド')
      end
    end

    context 'with small letters' do
      it 'converts small vowels' do
        expect(described_class.convert('ぁぃぅぇぉ')).to eq('ァィゥェォ')
      end

      it 'converts small ya-yu-yo' do
        expect(described_class.convert('ゃゅょ')).to eq('ャュョ')
      end

      it 'converts small tsu' do
        expect(described_class.convert('っ')).to eq('ッ')
      end
    end

    context 'with mixed text' do
      it 'converts words correctly' do
        expect(described_class.convert('おはよう')).to eq('ゴザジョグ')
      end

      it 'converts sentences with particles' do
        expect(described_class.convert('これはペンです')).to eq('ボセザメンゼグ')
      end

      it 'preserves non-Japanese characters' do
        expect(described_class.convert('あ1い2う')).to eq('ガ1ギ2グ')
      end

      it 'preserves spaces' do
        expect(described_class.convert('あい うえ')).to eq('ガギ グゲ')
      end
    end

    context 'with edge cases' do
      it 'converts empty string' do
        expect(described_class.convert('')).to eq('')
      end

      it 'handles string with only unconvertible characters' do
        expect(described_class.convert('123ABC')).to eq('123ABC')
      end
    end

    context 'with proper nouns' do
      it 'preserves クウガ without conversion' do
        expect(described_class.convert('クウガ')).to eq('クウガ')
      end

      it 'preserves リント without conversion' do
        expect(described_class.convert('リント')).to eq('リント')
      end

      it 'preserves ゲゲル without conversion' do
        expect(described_class.convert('ゲゲル')).to eq('ゲゲル')
      end

      it 'preserves グロンギ without conversion' do
        expect(described_class.convert('グロンギ')).to eq('グロンギ')
      end

      it 'converts text around proper nouns' do
        expect(described_class.convert('リントはクウガとたたかう')).to eq('リントザクウガドダダバグ')
      end

      it 'preserves multiple proper nouns in sentence' do
        expect(described_class.convert('グロンギがゲゲルをする')).to eq('グロンギガゲゲルゾグス')
      end
    end
  end

  describe '.num2grg' do
    context 'with basic numbers' do
      it 'converts 0 correctly' do
        expect(described_class.num2grg(0)).to eq('ゼゼソ')
      end

      it 'converts 1-8 correctly' do
        expect(described_class.num2grg(1)).to eq('パパン')
        expect(described_class.num2grg(2)).to eq('ドググ')
        expect(described_class.num2grg(3)).to eq('グシギ')
        expect(described_class.num2grg(4)).to eq('ズゴゴ')
        expect(described_class.num2grg(5)).to eq('ズガギ')
        expect(described_class.num2grg(6)).to eq('ギブグ')
        expect(described_class.num2grg(7)).to eq('ゲズン')
        expect(described_class.num2grg(8)).to eq('ゲギド')
      end
    end

    context 'with base-9 number system' do
      it 'converts 9 (base-9: 10) correctly' do
        result = described_class.num2grg(9)
        expect(result).to include('バギン')
      end

      it 'converts 10 (base-9: 11) correctly' do
        result = described_class.num2grg(10)
        expect(result).to include('バギン')
        expect(result).to include('パパン')
      end

      it 'converts larger numbers' do
        result = described_class.num2grg(81)
        expect(result).to include('バギン')
      end
    end
  end
end
