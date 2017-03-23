module Fastlane
  module Actions
    def self.jenkins?
      ENV.key?('JENKINS_URL')
    end
  end
end