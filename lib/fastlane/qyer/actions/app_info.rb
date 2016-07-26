require 'qma'
require 'qma/core_ext/object/to_column'
require 'fastlane_core'

module Fastlane
  module Actions
    module SharedValues
      QYER_PUBLISH_URL = :QYER_PUBLISH_URL
    end

    ##
    # App Info Action
    class AppInfoAction < Action
      def self.run(options)
        @file = options.fetch(:file)
        UI.user_error! 'You have to either pass an ipa or an apk file' unless @file

        @app = QMA::App.parse(@file)
        print_table!
      end

      def self.print_table!
        params = query_params
        params.merge(ipa_mobileprovision) if @app.os == 'iOS'

        FastlaneCore::PrintTable.print_values(config: params,
                                              title: 'Summary for app_info')
      end

      def self.query_params
        keys = %w(name release_version build_version identifier os)
        keys.each_with_object({}) do |key, obj|
          obj[key.to_sym] = @app.send(key.to_sym)
        end
      end

      def self.ipa_mobileprovision!
        params = {}
        return params if !@app.mobileprovision? || @app.mobileprovision.nil?

        @app.mobileprovision.mobileprovision.each do |key, value|
          next if key == 'DeveloperCertificates'

          name =
            case value
            when Array
              value.size > 1 ? "#{key} (#{value.size})" : key
            when Hash
              value.keys.size > 1 ? "#{key} (#{value.keys.size})" : key
            else
              key
            end

          params[name] = value.to_column
        end

        params
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                       env_name: 'APP_INFO_FILE',
                                       description: 'Path to your ipa/apk file. Optional if you use the `gym`, `ipa` or `xcodebuild` action. ',
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] || Dir['*.ipa'].last || Dir['*.apk'].last,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Couldn't find app file".red unless File.exist?(value)
                                       end)
        ]
      end

      def self.description
        'Parse and dump mobile app informations'
      end

      def self.details
        'parse and dump informations for ipa/apk file'
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
