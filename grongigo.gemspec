# frozen_string_literal: true

require_relative 'lib/grongigo'

Gem::Specification.new do |spec|
  spec.name = 'grongigo'
  spec.version = Grongigo::VERSION
  spec.authors = ['Yudai Takada']
  spec.email = ['t.yudai92@gmail.com']

  spec.summary = 'Grongigo programming language compiler - A programming language based on Grongi language from Kamen Rider Kuuga (Masked Rider Kuuga)'
  spec.description = 'Grongigo is a programming language compiler that transpiles Grongi language code to C language. Features include complete Grongigo syntax, base-9 number system, and C language transpilation.'
  spec.homepage = 'https://github.com/ydah/grongigo'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ydah/grongigo'
  spec.metadata['changelog_uri'] = 'https://github.com/ydah/grongigo/blob/main/CHANGELOG.md'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'bin'
  spec.executables = ['grongigo']
  spec.require_paths = ['lib']
end
