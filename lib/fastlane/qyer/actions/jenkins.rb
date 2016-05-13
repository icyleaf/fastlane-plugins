require 'net/http'
require 'json'
require 'time'

module Fastlane
  module Actions
    module SharedValues
      JENKINS_CHANGLOG = :JENKINS_CHANGLOG
      JENKINS_CVS_BRANCH = :JENKINS_CVS_BRANCH
      JENKINS_CVS_COMMIT = :JENKINS_CVS_COMMIT
      JENKINS_CI_URL = :JENKINS_CI_URL
    end

    ##
    # Jenkins Action
    class JenkinsAction < Action
      def self.run(params)
        raise 'Current environment is not ci' unless jenkins?

        if params[:force_build] == false &&
           ENV['GIT_COMMIT'] == ENV['GIT_PREVIOUS_SUCCESSFUL_COMMIT']

          message = 'Previous build was the latest commit. Skip this build'
          Helper.log.warn message.yellow
          raise message
        end

        fetch_changelog!
        fetch_jenkins_env!
      end

      def self.fetch_changelog!
        changes = []
        no = 1
        fetch_correct_changelog = false

        bid = ENV['BUILD_NUMBER'].to_i
        begin
          res = Net::HTTP.get_response(URI.parse("#{ENV['JOB_URL']}/#{bid}/api/json"))
          if res.is_a?(Net::HTTPSuccess)
            json = JSON.parse(res.body)
            if json['result'] == 'SUCCESS'
              fetch_correct_changelog = true
            else
              json['changeSet']['items'].each do |commit|
                date = DateTime.parse(commit['date']).strftime('%Y-%m-%d %H:%m')
                changes.push("#{no}. #{commit['msg']} [#{date}]")
                no += 1
              end
            end
          end

          bid -= 1
        end until fetch_correct_changelog || bid <= 0

        if changes.empty? && Helper.is_test?
          last_success_commit = ENV['GIT_PREVIOUS_SUCCESSFUL_COMMIT']
          git_logs = `git log --pretty="format:%s - %cn [%ci]" #{last_success_commit}..HEAD`.strip.gsub(' +0800', '')
          changes = git_logs.split("\n")
        end

        changelog = changes.join("\n")
        Actions.lane_context[SharedValues::JENKINS_CHANGLOG] = changelog
        ENV[SharedValues::JENKINS_CHANGLOG.to_s] = changelog
      end

      def self.fetch_jenkins_env!
        branch =
          if ENV['GIT_BRANCH'].to_s.empty?
            ENV['SVN_BRANCH']
          else
            ENV['GIT_BRANCH'].include?('/') ? ENV['GIT_BRANCH'].split('/').last : ENV['GIT_BRANCH']
          end

        Actions.lane_context[SharedValues::JENKINS_CVS_BRANCH] = branch
        ENV[SharedValues::JENKINS_CVS_BRANCH.to_s] = branch

        Actions.lane_context[SharedValues::JENKINS_CVS_COMMIT] = ENV['GIT_COMMIT']
        ENV[SharedValues::JENKINS_CVS_COMMIT.to_s] = ENV['GIT_COMMIT']

        Actions.lane_context[SharedValues::JENKINS_CI_URL] = ENV['BUILD_URL']
        ENV[SharedValues::JENKINS_CI_URL.to_s] = ENV['BUILD_URL']
      end

      def self.jenkins?
        ENV.key?('JENKINS_URL')
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :force_build,
                                       env_name: 'JENKINS_FORCE_BUILD',
                                       description: 'Force build if the commit same as previous success commit',
                                       default_value: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['JENKINS_CHANGLOG', 'Current jenkins build changelog'],
          ['JENKINS_CVS_BRANCH', 'Current jenkins build CVS branch name'],
          ['JENKINS_CVS_COMMIT', 'Current jenkins build CVS last commit'],
          ['JENKINS_CI_URL', 'Current jenkins build url']
        ]
      end

      def self.description
        'Jenkins utils tools'
      end

      def self.details
        'Jenkins utils tools like changelog, git details etc'
      end

      def self.author
        'icyleaf'
      end

      def self.is_supported?(platform)
        [:ios, :android, :mac].include? platform
      end
    end
  end
end
