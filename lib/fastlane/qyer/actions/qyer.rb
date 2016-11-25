require 'qma'

module Fastlane
  module Actions
    module SharedValues
      QYER_PUBLISH_URL = :QYER_PUBLISH_URL
    end

    ##
    # Qyer Action
    class QyerAction < Action
      def self.run(options)
        @options = options
        @user_key = options.fetch(:api_key)
        @config_file = options.fetch(:config_path)
        @host_type = options.fetch(:host_type).to_sym
        @file = options.fetch(:ipa)
        @file = options.fetch(:apk) unless @file
        UI.user_error! 'You have to either pass an ipa or an apk file' unless @file

        @app = AppInfo.parse(@file)
        @client = QMA::Client.new(@user_key, config_file: @config_file)

        print_table!
        upload!
      end

      def self.upload!
        UI.message 'Uploading to qma...'
        response = @client.upload(@file, host_type: @host_type, params: query_params)

        case response[:code]
        when 201
          new_upload(response)
        when 200
          found_exist(response)
        when 400..428
          fail_valid(response)
        else
          UI.user_error! json[:message].to_s
        end

        response[:code]
      end

      def self.new_upload(json)
        url = app_url(json[:entry])
        shared_url(url)

        UI.success 'Successful uploaded file'
        UI.success url
      end

      def self.found_exist(json)
        url = app_url(json[:entry], true)
        shared_url(url)

        UI.important 'This version had been uploaded.'
        UI.important url
      end

      def self.fail_valid(json)
        if json.empty?
          UI.user_error! 'Unkonwn error!'
        else
          errors = ["[ERROR] #{json[:message]}"]
          json[:entry].each_with_index do |(key, items), i|
            errors.push "#{i + 1}. #{key}"
            items.each do |item|
              errors.push "- #{item}"
            end
          end

          UI.user_error! errors.join("\n")
        end
      end

      def self.shared_url(url)
        Actions.lane_context[SharedValues::QYER_PUBLISH_URL] = url
        ENV[SharedValues::QYER_PUBLISH_URL.to_s] = url
      end

      def self.app_url(json, version = false)
        host = json['host']['external']
        slug = json['app']['slug']
        paths = [host, 'apps', slug]
        paths.push(json['version'].to_s) if version

        paths.join('/')
      end

      def self.query_params
        @params = {
          name: @app.name,
          device_type: @app.device_type,
          identifier: @app.identifier,
          release_version: @app.release_version,
          build_version: @app.build_version,
          channel: @options.fetch(:channel),
          branch: @options.fetch(:branch),
          last_commit: @options.fetch(:commit),
          ci_url: @options.fetch(:ci_url),
          changelog: @options.fetch(:changelog)
        }.merge(custom_data)
      end

      def self.custom_data
        params = @options[:custom_data] || {}

        if @app.os == 'iOS' && @app.mobileprovision && !@app.mobileprovision.empty?
          params[:profile_name] = @app.profile_name
          params[:profile_created_at] = @app.mobileprovision.created_date
          params[:profile_expired_at] = @app.mobileprovision.expired_date
          params[:devices] = @app.devices
        end

        if Actions.jenkins?
          params[:ci_name] = ENV['JOB_NAME']
          params[:git_url] = ENV['GIT_URL']
        end

        params
      end

      def self.print_table!
        params = {
          url: @client.config.send("#{@host_type}_host"),
          user_key: @user_key,
          file: @file
        }.merge(query_params)

        FastlaneCore::PrintTable.print_values(config: params,
                                              title: "Summary for qyer #{QMA::VERSION}",
                                              hide_keys: [:devices])
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: 'QYER_API_KEY',
                                       description: 'API Key',
                                       verify_block: proc do |value|
                                         raise 'No API key, please input again'.red unless value && !value.empty?
                                       end),
          # iOS Specific
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: 'QYER_IPA',
                                       description: 'Path to your IPA file. Optional if you use the `gym`, `ipa` or `xcodebuild` action. ',
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || Dir['*.ipa'].last,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Couldn't find ipa file".red unless File.exist?(value)
                                       end),
          # Android Specific
          FastlaneCore::ConfigItem.new(key: :apk,
                                       env_name: 'QYER_APK',
                                       description: 'Path to your APK file',
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] || Dir['*.apk'].last,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Couldn't find apk file".red unless File.exist?(value)
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
                                       default_value: Actions.lane_context[SharedValues::JENKINS_CHANGLOG],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :channel,
                                       env_name: 'QYER_CHANNEL',
                                       description: 'upload channel name',
                                       default_value: 'fastlane',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :branch,
                                       env_name: 'QYER_GIT_BRANCH',
                                       description: 'git branch name',
                                       default_value: Actions.lane_context[SharedValues::JENKINS_CVS_BRANCH],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :commit,
                                       env_name: 'QYER_GIT_COMMIT',
                                       description: 'git last commit',
                                       default_value: Actions.lane_context[SharedValues::JENKINS_CVS_COMMIT],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ci_url,
                                       env_name: 'QYER_CI_URL',
                                       default_value: Actions.lane_context[SharedValues::JENKINS_CI_URL],
                                       description: 'ci url',
                                       optional: true),

          FastlaneCore::ConfigItem.new(key: :config_path,
                                       env_name: 'QYER_CONFIG_PATH',
                                       description: 'The path to qma confiuration file',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :host_type,
                                       env_name: 'QYER_HOST_TYPE',
                                       description: 'The host type to upload host domain',
                                       default_value: 'external',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :custom_data,
                                       env_name: 'QYER_CUSTOM_DATA',
                                       description: 'Custom data to build query params',
                                       optional: true)
        ]
      end

      def self.description
        'Upload a new build to QMA'
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
