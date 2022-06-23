require 'plist'
require 'xcodeproj'

module Fastlane
  module Actions

    module SharedValues
      XCODE_PROJECT_SCHEMES = :XCODE_PROJECT_SCHEMES
    end

    class GetXcodeSchemesAction < Action
      def self.run(params)
        xcodeproj_path = params[:xcodeproj]
        UI.user_error! "Not found xcode project: #{xcodeproj_path}" unless Dir.exist?(xcodeproj_path)

        UI.success "Dumping Xcode project's schemes: "
        schemes = Xcodeproj::Project.schemes(xcodeproj_path)
        schemes.each do |scheme|
          UI.success "- #{scheme}"
        end

        Actions.lane_context[SharedValues::XCODE_PROJECT_SCHEMES] = schemes
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Get Xcode project configurations'
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
          ['XCODE_PROJECT_SCHEMES', 'the schemes of xcode project']
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
