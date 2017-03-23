require 'qma'
require 'qma/core_ext/object/to_column'
require 'terminal-table'

module Fastlane
  module Actions
    ##
    # App Info Action
    class AppInfoAction < Action
      def self.run(options)
        @file = options.fetch(:file)
        UI.user_error! 'You have to either pass an ipa or an apk file' unless @file
        @file = File.expand_path(@file)
        @app = AppInfo.parse(@file)

        print_table!
      end

      def self.print_table!
        table = query_params
        table = ipa_mobileprovision(table) if @app.os == 'iOS'
        table.title = 'Summary for app_info'
        puts "\n#{table}\n"
      end

      def self.query_params
        keys = %w(name release_version build_version identifier os)
        Terminal::Table.new do |t|
          keys.each do |key|
            columns = []
            columns << key.capitalize
            columns << @app.send(key.to_sym).to_column

            t << columns
          end
        end
      end

      def self.ipa_mobileprovision(table)
        return table unless @app.mobileprovision && !@app.mobileprovision.empty?

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

          columns = []
          columns << name
          columns << value.to_column

          table << columns
        end

        table
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
