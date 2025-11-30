# frozen_string_literal: true

module Grongigo
  # Grongigo numerals (base-9, English-based)
  DIGITS = {
    'ゼゼソ' => 0,  # zero
    'パパン' => 1,  # one (wan)
    'ドググ' => 2,  # two
    'グシギ' => 3,  # three
    'ズゴゴ' => 4,  # four
    'ズガギ' => 5,  # five
    'ギブグ' => 6,  # six
    'ゲズン' => 7,  # seven
    'ゲギド' => 8,  # eight
    'バギン' => 9   # nine (10 in base-9)
  }.freeze

  # Numeric operators
  NUMBER_OPS = {
    'ド' => :add,      # addition
    'グ' => :multiply  # multiplication
  }.freeze

  # Keywords (types)
  TYPE_KEYWORDS = {
    'ゲギグウ' => 'int',    # integer (seisuu)
    'ロジ' => 'char',       # character (moji)
    'ズゾウ' => 'float',    # floating point (fudou)
    'ザダダス' => 'double', # double (fukufudou -> zadadas)
    'バサ' => 'void',       # void (kara)
    'バゴ' => 'long',       # long (naga)
    'ジジバギ' => 'short',  # short (mijikai)
    'ブゾウ' => 'unsigned'  # unsigned (mufugou)
  }.freeze

  # Keywords (control structures)
  CONTROL_KEYWORDS = {
    'ジョウベン' => 'if',       # if (jouken)
    'ゾバ' => 'else',           # else (hoka)
    'ガギザ' => 'while',        # while (aida)
    'ブシバゲギ' => 'for',      # for (kurikaeshi)
    'ロゾス' => 'return',       # return (modosu)
    'ブゲス' => 'break',        # break (nukeru)
    'ヅヅゲス' => 'continue',   # continue (tsuzukeru)
    'ゲンダブ' => 'switch',     # switch (sentaku)
    'ダガギ' => 'case',         # case (baai)
    'ビデギ' => 'default',      # default (kitei)
    'ジョウジ' => 'printf',     # printf (hyouji)
    'ジュウソブ' => 'scanf'     # scanf (juuryoku -> juusobu)
  }.freeze

  # Keywords (other)
  OTHER_KEYWORDS = {
    'ボウゾウ' => 'struct',     # struct (kouzou)
    'バダデギギ' => 'typedef',  # typedef (katatеigi)
    'ゴゴビガ' => 'sizeof',     # sizeof (ookisa)
    'ル' => 'NULL',             # NULL (mu)
    'ギン' => '1',              # true (shin)
    'ギ' => '0',                # false (gi) - need to distinguish from variable names
    'ゴロ' => 'main',           # main (omo)
    'パザ' => '',               # function definition marker (waza)
    'ザジレ' => '{',            # block start (hajime)
    'ゴパシ' => '}'             # block end (owari)
  }.freeze

  # Operators
  OPERATORS = {
    'ダグ' => '+',              # add (tasu)
    'ジブ' => '-',              # subtract (hiku)
    'バゲス' => '*',            # multiply (kakeru)
    'パス' => '/',              # divide (waru)
    'ガラシ' => '%',            # modulo (amari)
    'ギセス' => '=',            # assign (ireru)
    'ジドギギ' => '==',         # equal (hitoshii)
    'ジドギグバギ' => '!=',     # not equal
    'ギョウバシ' => '<',        # less than (shounari)
    'ザギバシ' => '>',          # greater than (dainari)
    'ギバ' => '<=',             # less or equal (ika)
    'ギジョウ' => '>=',         # greater or equal (ijou)
    'バヅ' => '&&',             # and (katsu)
    'ラダパ' => '||',           # or (mataha)
    'ジデギ' => '!',            # not (hitei)
    'ガンド' => '&',            # bitwise and (ando)
    'ゴゴ' => '|',              # bitwise or (oa -> goga)
    'ダグダグ' => '++',         # increment (tasu tasu)
    'ジブジブ' => '--'          # decrement (hiku hiku)
  }.freeze

  # Merge all keywords
  ALL_KEYWORDS = TYPE_KEYWORDS
                 .merge(CONTROL_KEYWORDS)
                 .merge(OTHER_KEYWORDS)
                 .freeze

  # Proper nouns not converted in Grongigo
  PROPER_NOUNS = %w[
    クウガ
    リント
    ゲゲル
    グロンギ
    グセパ
    バグンダダ
    ゲリザギバスゲゲル
    ザギバスゲゲル
  ].freeze

  # Japanese to Grongigo conversion table (for reference)
  JAPANESE_TO_GRONGIGO = {
    # Basic rows
    'あ' => 'ガ', 'い' => 'ギ', 'う' => 'グ', 'え' => 'ゲ', 'お' => 'ゴ',
    'か' => 'バ', 'き' => 'ビ', 'く' => 'ブ', 'け' => 'ベ', 'こ' => 'ボ',
    'さ' => 'ガ', 'し' => 'ギ', 'す' => 'グ', 'せ' => 'ゲ', 'そ' => 'ゴ',
    'た' => 'ダ', 'ち' => 'ヂ', 'つ' => 'ヅ', 'て' => 'デ', 'と' => 'ド',
    'な' => 'バ', 'に' => 'ビ', 'ぬ' => 'ブ', 'ね' => 'ベ', 'の' => 'ボ',
    'は' => 'ザ', 'ひ' => 'ジ', 'ふ' => 'ズ', 'へ' => 'ゼ', 'ほ' => 'ゾ',
    'ま' => 'ラ', 'み' => 'リ', 'む' => 'ル', 'め' => 'レ', 'も' => 'ロ',
    'や' => 'ジャ', 'ゆ' => 'ジュ', 'よ' => 'ジョ',
    'ら' => 'サ', 'り' => 'シ', 'る' => 'ス', 'れ' => 'セ', 'ろ' => 'ソ',
    'わ' => 'パ',
    # Dakuon (voiced)
    'が' => 'ガ', 'ぎ' => 'ギ', 'ぐ' => 'グ', 'げ' => 'ゲ', 'ご' => 'ゴ',
    'ざ' => 'ザ', 'じ' => 'ジ', 'ず' => 'ズ', 'ぜ' => 'ゼ', 'ぞ' => 'ゾ',
    'だ' => 'ザ', 'ぢ' => 'ジ', 'づ' => 'ズ', 'で' => 'ゼ', 'ど' => 'ゾ',
    'ば' => 'ダ', 'び' => 'ヂ', 'ぶ' => 'ヅ', 'べ' => 'デ', 'ぼ' => 'ド',
    'ぱ' => 'マ', 'ぴ' => 'ミ', 'ぷ' => 'ム', 'ぺ' => 'メ', 'ぽ' => 'モ'
    # Special particles (but not supported)
    # 'が' => 'グ', 'の' => 'ン', 'は' => 'パ', 'を' => 'ゾ' (when used as particles)
  }.freeze
end
