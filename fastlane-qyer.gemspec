# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/qyer/version'

Gem::Specification.new do |spec|
  spec.name          = "fastlane-qyer"
  spec.version       = Fastlane::Qyer::VERSION
  spec.authors       = ["icyleaf"]
  spec.email         = ["icyleaf.cn@gmail.com"]

  spec.summary       = "qyer mobile app action for fastlane"
  spec.description   = "qyer mobile app action(test, build, upload) for fastlane"
  spec.homepage      = "http://github.com/icyleaf/fastlane-qyer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "qyer-mobile-app", "~> 0.3.1"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fastlane", "~> 1.0"
end
