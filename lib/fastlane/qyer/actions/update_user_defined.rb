require 'xcodeproj'
require 'plist'
require 'awesome_print'

module Fastlane
  module Actions
    class UpdateUserDefinedAction < Action
      def self.run(params)
        @project_path = params[:project_path]
        UI.user_error!("Could not find Xcode project") unless File.exist?(@project_path)
        UI.user_error!('Please pass the name of user-defined setting') unless params[:name]
        UI.user_error!('Please pass the value of user-defined setting') unless params[:value]

        @xcode_hepler = Fastlane::Qyer::Helper::XcodeHelper.new(@project_path)

        @xcode_hepler.update_build_setting(params[:target], params[:name], params[:value], params[:configuration])
        true
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_path,
                                       env_name: 'QYER_UPDATE_USER_DEFINES_PROJECT_PATH',
                                       description: 'Project (.xcodeproj) file to use to build app',
                                       default_value: Dir['*.xcodeproj'].first,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :target,
                                       env_name: 'QYER_UPDATE_USER_DEFINES_TARGET',
                                       description: 'The target name of the project',
                                       default_value: 0,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: 'QYER_UPDATE_USER_DEFINES_NAME',
                                       description: 'The name of variable'),
          FastlaneCore::ConfigItem.new(key: :value,
                                       env_name: 'QYER_UPDATE_USER_DEFINES_VALUE',
                                       description: 'The value of variable'),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: 'QYER_UPDATE_USER_DEFINES_CONFIGURATION',
                                       description: 'The name of build configuration (Set all if leave it)',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :overwrite,
                                       env_name: 'QYER_UPDATE_USER_DEFINES_OVERWRITE',
                                       description: 'Overwrite if the variable is exist',
                                       default_value: false,
                                       is_string: false)
        ]
      end

      def self.output
        []
      end

      def self.description
        'Custom user-defined variable for xcode project'
      end

      def self.details
        'Custom user-defined variable for xcode project'
      end

      def self.author
        'icyleaf'
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
