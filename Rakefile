require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'fastlane'
require 'fastlane-qyer'
require 'awesome_print'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :helper do
  project_path = '/Users/wiiseer/Development/qyer/ios/FastlaneTest/FastlaneTest.xcodeproj'
  helper = Fastlane::Qyer::Helper::XcodeHelper.new(project_path)
  #
  # helper.configurations
  # ap helper.project
  ap helper.update_build_setting('FastlaneTest', 'debugonly', 'world', 'Debug')

  ap helper.target('FastlaneTest').build_configurations
end