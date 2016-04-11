require 'xcodeproj'
require 'plist'


module Fastlane
  module Actions
    module SharedValues
      XCODE_PROJECT_PATH = :XCODE_PROJECT_PATH
      XCODE_PROJECT_NAME = :XCODE_PROJECT_NAME
      XCODE_APP_IDENTIFIER = :XCODE_APP_IDENTIFIER
    end

    class XcodeBootstrapAction < Action

      def self.run(params)
        @project_path = params[:project_path]
        @project_name = @project_path.split('/')[-1]
        @use_cocoapods = params[:cocoapods]

        @build_configuration_name = params[:build_configuration_name] || 'AdHoc'.freeze
        @build_configuration_base = params[:build_configuration_base] || :release

        UI.user_error!("Please pass the path to the project (.xcodeproj)") unless @project_path.end_with?(".xcodeproj")
        UI.user_error!("Could not find Xcode project") unless File.exist?(@project_path)

        @project = Xcodeproj::Project.open(@project_path)
        @target_name = @project.targets[0].name

        if @use_cocoapods
          if pods_exists?
            podfile_bootstrap!
          else
            UI.user_error("Podfile does not exist.")
          end
        end

        xcode_bootstrap!

        # return as success
        UI.success("bootstrap up! 🚀")
      end

      def self.xcode_bootstrap!
      end

      def self.podfile_bootstrap!
        add_build_configuration_to_podfile = "xcodeproj '#{project_name.split('.')[0]}', '#{build_configuration_name}' => :#{build_configuration_base.to_s}"

        command = %Q{cat #{podfile_path} | grep "#{add_build_configuration_to_podfile}" | wc -l}
        r = Actions.sh(command, log: false)
        unless r.strip.to_i > 0
          UI.message("Adding #{build_configuration_name} build configuration to Podfile")
          tempfile = "#{podfile_path}.tmp"
          File.open(tempfile, 'w') do |f|
            File.foreach(podfile_path) do |line|
              match_line = /target(\s+)["|']#{target_name}["|'](\s+)do/
              f.puts line
              if StringScanner.new(line).match?(match_line)
                f.puts "\t#{add_build_configuration_to_podfile}"
              end
            end
          end

          File.delete(podfile_path)
          File.rename(tempfile, podfile_path)
        end
      end

      def self.pods_exists?
        File.exist?(File.join(@project_path, 'Podfile'))
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_path,
                                       env_name: 'XCODE_PROJECT_PATH',
                                       description: 'Project (.xcodeproj) file to use to build app',
                                       default_value: Dir['*.xcodeproj'].size > 0 ? Dir['*.xcodeproj'].first : ''),
          FastlaneCore::ConfigItem.new(key: :cocoapods,
                                       env_name: 'XCODE_COCOAPODS_SUPPORT',
                                       description: 'Project need cocoapods support(default is `false`)',
                                       is_string: false,
                                       default_value: false),
          # FastlaneCore::ConfigItem.new(key: :app_identifier,
          #                              env_name: 'XCODE_APP_IDENTIFIER',
          #                              description: 'The bundle identifier of your app',
          #                              default_value: ENV['PRODUCE_APP_IDENTIFIER']),
          FastlaneCore::ConfigItem.new(key: :build_configuration_name,
                                       env_name: 'XCODE_BUILD_CONFIGURATION_NAME',
                                       description: 'The build configuration name of your app',
                                       default_value: 'AdHoc'),
          FastlaneCore::ConfigItem.new(key: :build_configuration_base,
                                       env_name: 'XCODE_BUILD_CONFIGURATION_BASE',
                                       description: 'The build configuration base name of your app',
                                       default_value: 'release'),
          FastlaneCore::ConfigItem.new(key: :app_suffix,
                                       env_name: 'XCODE_APP_SUFFIX',
                                       description: 'The user defined app name&identifier suffix of your app',
                                       default_value: {
                                         'Debug': {
                                           name: '开发版',
                                           identifier: '.debug'
                                          },
                                          'AdHoc': {
                                            name: '内测版',
                                            identifier: '.adhoc'
                                          },
                                          'Release': {
                                            name: '',
                                            identifier: ''
                                          },
                                        }),
        ]
      end

      def self.output
        [
          ['XCODE_PROJECT_PATH', 'The xcode project path of your app'],
          ['XCODE_PROJECT_NAME', 'The xcode project name of your app'],
          ['XCODE_APP_IDENTIFIER', 'The identifier of your appp'],
        ]
      end

      def self.description
        'Easy bootstrap xcode project'
      end

      def self.details
        "Quick append build configuration and support cocoapods"
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
