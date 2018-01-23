# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'momentum/version'

Gem::Specification.new do |spec|
  spec.name          = "momentum"
  spec.version       = Momentum::VERSION
  spec.authors       = ["Joey Aghion"]
  spec.email         = ["joey@aghion.com"]
  spec.description   = %q{Utilities for working with OpsWorks apps in the style of Artsy Engineering.}
  spec.summary       = %q{Utilities for working with OpsWorks apps in the style of Artsy Engineering.}
  spec.homepage      = "https://github.com/artsy/momentum"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 1.30"
  spec.add_dependency "berkshelf", ">= 4.3"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
