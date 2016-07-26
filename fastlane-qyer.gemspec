# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/qyer/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-qyer'
  spec.version       = Fastlane::Qyer::VERSION
  spec.authors       = ['icyleaf']
  spec.email         = ['icyleaf.cn@gmail.com']

  spec.summary       = 'qyer mobile app actions for fastlane'
  spec.description   = 'qyer mobile app actions(test, build, upload) for fastlane'
  spec.homepage      = 'http://github.com/icyleaf/fastlane-qyer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'qyer-mobile-app', '>= 0.7.0'
  spec.add_dependency 'xcodeproj', '~> 0.28.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'fastlane', '>= 1.34.0'
  spec.add_development_dependency 'awesome_print'
end
