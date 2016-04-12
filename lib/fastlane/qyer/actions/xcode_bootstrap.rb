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

        UI.user_error!("Please pass the path to the project (.xcodeproj)") unless @project_path.to_s.end_with?(".xcodeproj")
        UI.user_error!("Could not find Xcode project") unless File.exist?(@project_path)

        @project_name = @project_path.split('/')[-1]
        @use_cocoapods = params[:cocoapods]
        @app_suffix = params[:app_suffix]
        @app_identifier = ENV['PRODUCE_APP_IDENTIFIER']

        app_suffix_valid!

        @build_configuration_name = params[:build_configuration_name]
        @build_configuration_base = params[:build_configuration_base]

        @project = Xcodeproj::Project.open(@project_path)
        UI.user_error!("Not found any target in project") if @project.targets.size == 0

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
        unless @project.build_configuration_list[@build_configuration_name]
          add_build_configuration(@build_configuration_name, @build_configuration_base)
          @project.save
        else
          UI.user_error!("Build configuration `#{@build_configuration_name}` is exists, check again.")
        end
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

      def self.add_build_configuration(name, base)
        @project.add_build_configuration(name, base)

        project_target = @project.targets[0]
        code_sign = (base == :release) ? 'iPhone Distribution' : 'iPhone Developer'

        target_configuration = project_target.add_build_configuration(name, base)
        target_configuration.base_configuration_reference = pod_build_configuration(@build_configuration_name)
        target_configuration.build_settings['SDKROOT'] = 'iphoneos'
        target_configuration.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = @app_identifier
        target_configuration.build_settings['INFOPLIST_FILE'] = info_plist_path
        target_configuration.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = code_sign
        target_configuration.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ["#{name.upcase}=1"]

        target_configuration
      end

      def self.pod_build_configuration(name)
        @project.objects.select { |obj| obj.isa == 'PBXFileReference' &&
          !obj.name.nil? &&
          obj.name.include?(".#{name.downcase}.xcconfig")
        }[0]
      end

      def self.info_plist_path
        @project.objects.select { |obj| obj.isa == 'XCBuildConfiguration' &&
          !obj.build_settings['PRODUCT_BUNDLE_IDENTIFIER'].nil?
        }[0].build_settings['INFOPLIST_FILE']
      end

      def self.app_suffix_valid!
        UI.user_error!('Invaild app suffix format. please check `fastlane action xcode_bootstrap`') unless @app_suffix.class == Hash
        @app_suffix.each do |name, dict|
          UI.user_error!() unless dict.class == Hash
          UI.user_error!() unless dict.keys == [:name, :identifier]
          dict.each do |key, value|
            UI.user_error!() unless value.class == String
          end
        end
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_path,
                                       env_name: 'XCODE_PROJECT_PATH',
                                       description: 'Project (.xcodeproj) file to use to build app',
                                       default_value: Dir['*.xcodeproj'].first,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :cocoapods,
                                       env_name: 'XCODE_COCOAPODS_SUPPORT',
                                       description: 'Project need cocoapods support(default is `false`)',
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :build_configuration_name,
                                       env_name: 'XCODE_BUILD_CONFIGURATION_NAME',
                                       description: 'The build configuration name of your app',
                                       default_value: 'AdHoc'),
          FastlaneCore::ConfigItem.new(key: :build_configuration_base,
                                       env_name: 'XCODE_BUILD_CONFIGURATION_BASE',
                                       description: 'The build configuration base name of your app',
                                       is_string: false,
                                       default_value: :release),
          FastlaneCore::ConfigItem.new(key: :app_suffix,
                                       env_name: 'XCODE_APP_SUFFIX',
                                       description: 'The user defined app name&identifier suffix of your app',
                                       is_string: false,
                                       default_value: {
                                         'Debug': {
                                           name: '开发版',
                                           identifier: '.debug'
                                          },
                                          'AdHoc': {
                                            name: '内测版',
                                            identifier: ''
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
