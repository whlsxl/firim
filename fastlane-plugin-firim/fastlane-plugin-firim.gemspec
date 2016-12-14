# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/firim/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-firim'
  spec.version       = Fastlane::Firim::VERSION
  spec.author        = %q{whlsxl}
  spec.email         = %q{whlsxl@gmail.com}

  spec.summary       = %q{firim}
  spec.homepage      = "https://github.com/whlsxl/firim/tree/master/fastlane-plugin-firim"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  # fastlane dependencies
  spec.add_dependency 'firim', '~> 0'

  # Development only
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
end
