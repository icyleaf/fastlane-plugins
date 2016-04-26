require 'xcodeproj'
require 'plist'

module Fastlane
  module Qyer
    module Helper
      class XcodeHelper
        def initialize(project_path)
          @project_path = project_path || Dir['*.xcodeproj'].first
        end

        def target(name)
          if name.is_a?(Integer)
            project.targets[name]
          else
            targets = project.targets.select { |t| t.name == name }
            targets.empty? ? nil : targets[0]
          end
        end

        def info
          @info ||= Plist.parse_xml(info_plist_path)
        end

        def update_build_setting(target_name, key, value, config_name = nil)
          if config_name.to_s.empty?
            update_all_build_setting(target_name, key, value)
          else
            update_build_setting_by_name(target_name, config_name, key, value)
          end
        end

        def update_all_build_setting(target_name, key, value)
          target(target_name).build_configurations.each do |configuration|
            configuration.build_settings[key] = value
          end
          project.save
        end

        def update_build_setting_by_name(target_name, config_name, key, value)
          if has_configuration?(target(target_name), config_name)
            target(target_name).build_configurations.each do |configuration|
              configuration.build_settings[key] = value if configuration.name == config_name
            end
            project.save
          end
        end

        def has_configuration?(target, name)
          !target.build_configurations.select {|c| c.name == name }.empty?
        end

        def info_plist_path
          unless @info_plist_path
            path = project.objects.select { |obj| obj.isa == 'XCBuildConfiguration' && !obj.build_settings['PRODUCT_BUNDLE_IDENTIFIER'].nil? }[0].build_settings['INFOPLIST_FILE']
            @info_plist_path = File.join(File.path(@project_path), '..', path)
          end

          @info_plist_path
        end

        def project
          @project ||= Xcodeproj::Project.open(@project_path)
        end
      end
    end
  end
end