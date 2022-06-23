require 'plist'
require 'xcodeproj'

module Fastlane
  module Actions
    class GetTargetIdentiferAction < Action
      def self.run(params)
        target_filter = params[:target]
        project = Xcodeproj::Project.open(params[:xcodeproj])
        targets = project.targets.select { |target| target.name.match(target_filter) }

        UI.user_error! "Not found target: #{target_filter}" if targets.empty?

        target = targets[0]
        target.build_configuration_list.build_configurations.each do |build_configuration|
          puts build_configuration.name #.to_s.match(/CODE_SIGN_IDENTITY.*/)
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Send a success/error message to your [Wechat Work](https://work.weixin.qq.com/) group'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: 'UAP_XCODEPROJ',
                                       description: 'The url of webhook',
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :target,
                                       env_name: 'UAP_TARGET',
                                       description: 'The value of target',
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :export_method,
                                       env_name: 'UAP_EXPORT_METHOD',
                                       description: 'The value of export method',
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :identifier,
                                       env_name: 'UAP_INDENTIFIER',
                                       description: 'The value of identifier',
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :profile,
                                       env_name: 'UAP_PROFILE',
                                       description: 'The value of profile',
                                       type: String,
                                       optional: true)
        ]
      end

      def self.category
        :misc
      end

      def self.authors
        ['icyleaf']
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
