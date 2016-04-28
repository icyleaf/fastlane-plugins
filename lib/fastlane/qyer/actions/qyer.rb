module Fastlane
  module Actions
    ##
    # Qyer Action
    class QyerAction < Action
      ARGS_MAP = {
        api_key: '--key',
        ipa: '--file',
        apk: '--file',
        slug: '--slug',
        changelog: '--changelog',
        branch: '--branch',
        channel: '--channel',
        commit: '--commit',
        ci_url: '--ci-url'
      }.freeze

      def self.run(params)
        build_args = params_to_build_args(params)
        build_args = build_args.join(' ')

        core_command = "qma publish #{build_args}"
        command = "set -o pipefail && #{core_command} --verbose"

        Actions.sh(command)
      rescue Exception => e
        raise "App 上传失败，请检查错误提示：#{e}".red
      end

      def self.params_to_build_args(config)
        params = config.values

        params = params.delete_if { |_k, v| v.nil? }
        params = fill_in_default_values(params)

        params.collect do |k, v|
        value = (v.to_s.empty? ? '""' : "\"#{v}\"")
          "#{ARGS_MAP[k]} #{value}".strip
        end.compact
      end

      def self.fill_in_default_values(params)
        case Actions.lane_context[:PLATFORM_NAME]
        when :ios
          ipa = ENV['QYER_IPA']
          params[:ipa] ||= ipa if ipa
        when :android
          apk = ENV['QYER_APK']
          params[:apk] ||= apk if apk
        else
          raise 'You have to either pass an ipa or an apk file'.red
        end

        api_key = ENV['QYER_API_KEY']
        params[:api_key] ||= api_key if api_key

        app_name = ENV['QYER_APP_NAME']
        params[:app_name] ||= app_name if app_name

        slug = ENV['QYER_SLUG']
        params[:slug] ||= slug if slug

        channel = ENV['QYER_CHANNEl']
        params[:channel] ||= channel if channel

        changelog = ENV['JENKINS_CHANGLOG'] || ENV['QYER_CHANGELOG']
        params[:changelog] ||= changelog if changelog

        branch = ENV['QYER_CVS_BRANCH']
        params[:branch] ||= branch if branch

        commit = ENV['JENKINS_CVS_COMMIT'] || ENV['QYER_CVS_COMMIT']
        params[:commit] ||= commit if commit

        ci_url = ENV['JENKINS_CI_URL'] || ENV['QYER_CI_URL']
        params[:ci_url] ||= ci_url if ci_url

        params
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: 'QYER_API_KEY',
                                       description: 'API Key for Qyer Mobile AdHoc Access',
                                       verify_block: proc do |value|
                                         fail "No API Key for Qyer Mobile AdHoc given, pass using `api_key: 'token'`".red unless value && !value.empty?
                                       end),
          # iOS Specific
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: 'QYER_IPA',
                                       description: 'Path to your IPA file. Optional if you use the `gym`, `ipa` or `xcodebuild` action. ',
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || Dir['*.ipa'].last,
                                       optional: true,
                                       verify_block: proc do |value|
                                         fail "Couldn't find ipa file at path '#{value}'".red unless File.exist?(value)
                                       end),
          # Android Specific
          FastlaneCore::ConfigItem.new(key: :apk,
                                       env_name: 'QYER_APK',
                                       description: 'Path to your APK file',
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] || Dir['*.apk'].last || Dir[File.join('app', 'build', 'outputs', 'apk', 'app-qyer-release.apk')].last,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Couldn't find apk file at path '#{value}'".red unless File.exist?(value)
                                       end),

          FastlaneCore::ConfigItem.new(key: :app_name,
                                       env_name: 'QYER_APP_NAME',
                                       description: 'App Name',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :slug,
                                       env_name: 'QYER_SLUG',
                                       description: 'URL Slug',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :changelog,
                                       env_name: 'QYER_CHANGELOG',
                                       description: 'Changelog',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :channel,
                                       env_name: 'QYER_CHANNEL',
                                       description: 'upload channel name',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :branch,
                                       env_name: 'QYER_GIT_BRANCH',
                                       description: 'git branch name',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :commit,
                                       env_name: 'QYER_GIT_COMMIT',
                                       description: 'git last commit',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ci_url,
                                       env_name: 'QYER_CI_URL',
                                       description: 'ci url',
                                       optional: true)
        ]
      end

      def self.description
        'Upload a new build to Qyer Mobile System'
      end

      def self.details
        'More information on the qyer-mobile-app project page: https://github.com/icyleaf/qyer-mobile-app'
      end

      def self.author
        'icyleaf'
      end

      def self.is_supported?(platform)
        [:ios, :android].include? platform
      end
    end
  end
end
