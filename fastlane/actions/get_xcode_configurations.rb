require 'plist'
require 'xcodeproj'

module Fastlane
  module Actions

    module SharedValues
      XCODE_PROJECT_CONFIGURATIONS = :XCODE_PROJECT_CONFIGURATIONS
    end


    class GetXcodeConfigurationsAction < Action
      def self.run(params)
        xcodeproj_path = params[:xcodeproj]
        UI.user_error! "Not found xcode project: #{xcodeproj_path}" unless Dir.exist?(xcodeproj_path)

        UI.success "Dumping Xcode project's configurations: "
        xcodeproj = Xcodeproj::Project.open(xcodeproj_path)
        configurations = xcodeproj.build_configurations.map(&:name)
        configurations.each do |configuration|
          UI.success "- #{configuration}"
        end

        Actions.lane_context[SharedValues::XCODE_PROJECT_CONFIGURATIONS] = configurations
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Get Xcode project schemes'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: 'GET_XCODE_SCHEMES_XCODEPROJ',
                                       description: 'The path of xcode project',
                                       type: String)
        ]
      end

      def self.output
        [
          ['XCODE_PROJECT_CONFIGURATIONS', 'the configurations of xcode project']
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
