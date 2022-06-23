module Fastlane
  module Actions
    class UpdateEntitlementsAction < Action
      require 'plist'

      def self.run(params)
        key = params[:key]
        value = params[:value]

        UI.message("Entitlements File: #{params[:entitlements_file]}")
        UI.message("Update key: #{key} to #{value}")

        entitlements_file = params[:entitlements_file]
        UI.user_error!("Could not find entitlements file at path '#{entitlements_file}'") unless File.exist?(entitlements_file)

        # parse entitlements
        result = Plist.parse_xml(entitlements_file)
        UI.user_error!("Entitlements file at '#{entitlements_file}' cannot be parsed.") unless result

        old_value = result[key]
        # UI.user_error!("No existing key #{key}. Please make sure it in the entitlements file.") unless old_value && value.nil?a

        UI.message("Old value: #{old_value}")
        if value.empty?
          result.delete(key)
          UI.message("Old value is removed")
        else
          result[key] = params[:identifiers]
          UI.message("New value: #{result[key]}")
        end

        result.save_plist(entitlements_file)
        UI.message("New value: #{result[key]}")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'This action changes the value of given key in the entitlements file'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :entitlements_file,
                                       env_name: "FL_UPDATE_ENTITLEMENTS_FILE_PATH", # The name of the environment variable
                                       description: "The path to the entitlement file which contains the keychain access groups", # a short description of this parameter
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a path to an entitlements file. ") unless value.include?(".entitlements")
                                         UI.user_error!("Could not find entitlements file") if !File.exist?(value) && !Helper.test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :key,
                                       env_name: "FL_UPDATE_ENTITLEMENTS_KEY",
                                       description: "An key of entitlements. Eg. 'your.keychain.access.groups.identifiers'",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :value,
                                       env_name: "FL_UPDATE_ENTITLEMENTS_VALUE",
                                       description: "An value of entitlements, to remove set it nil")
        ]
      end

      def self.category
        :project
      end

      def self.authors
        ['icyleaf']
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'update_entitlements(
            entitlements_file: "/path/to/entitlements_file.entitlements",
            key: "your.keychain.access.groups.identifiers",
            value: "value"
          )'
        ]
      end
    end
  end
end
