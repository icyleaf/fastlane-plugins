module Fastlane
  module Actions
    class UpdateTargetProvisioningAction < Action
      def self.run(params)
        require 'plist'
        require 'xcodeproj'

        project = Xcodeproj::Project.open(params[:xcodeproj])
      end

      # # 手动设置 Profile
      # identifiers = [
      #   {
      #     target: 'HaoHaoZhu',
      #     identifier: 'com.haohaozhu.hhz'
      #   },
      #   {
      #     target: 'NotificationService',
      #     identifier: 'com.haohaozhu.hhz.NotificationService'
      #   }
      # ]

      # identifiers.each do |item|
      #   env_key = "sigh_#{item[:identifier]}_#{export_method}_profile-path"
      #   profile_file = ENV[env_key]

      #   update_project_provisioning(
      #     xcodeproj: 'HaoHaoZhu.xcodeproj',
      #     profile: profile_file,
      #     target_filter: item[:target]
      #   )
      # end

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
                                       description: 'The type of message',
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :export_method,
                                       env_name: 'UAP_TARGET',
                                       description: 'The type of message',
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :identifier,
                                       env_name: 'UAP_INDENTIFIER',
                                       description: 'The content of message',
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :profile,
                                       env_name: 'UAP_PROFILE',
                                       description: 'The path of profile',
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
