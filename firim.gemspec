# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'firim/version'

Gem::Specification.new do |spec|
  spec.name          = "firim"
  spec.version       = Firim::VERSION
  spec.authors       = ["whlsxl"]
  spec.email         = ["whlsxl+g@gmail.com"]

  spec.summary       = %q{fir.im command tool}
  spec.description   = "fir.im command tool,\n Upload ipa to fir.im"
  spec.homepage      = "https://github.com/whlsxl/firim"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = Dir["lib/**/*"] + %w( bin/firim README.md )
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # fastlane dependencies
  spec.add_dependency 'fastlane_core', '>= 0.52.0', '< 1.0.0' # all shared code and dependencies
  spec.add_dependency 'credentials_manager', '>= 0.16.0', '< 1.0.0'
  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'faraday_middleware', '~> 0.9'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
