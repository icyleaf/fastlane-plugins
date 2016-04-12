describe Fastlane::Actions::XcodeBootstrapAction do

  describe 'Information' do
    subject { Fastlane::Actions::XcodeBootstrapAction }

    it 'has a author name' do
      expect(subject.author).to eq("icyleaf")
    end

    it 'has a details' do
      expect(subject.details).not_to be_empty
    end

    it 'has a description' do
      expect(subject.description).not_to be_empty
    end

    context 'when platform mac, support ' do
      it { expect(subject.is_supported?(:mac)).to be true }
    end

    context 'when platform ios, support ' do
      it { expect(subject.is_supported?(:ios)).to be true }
    end

    context 'when platform andrid, not support ' do
      it { expect(subject.is_supported?(:andrid)).not_to be true }
    end
  end

  describe "Xcode bootstrap Integration" do
    # Variables
    let (:test_path) { "/tmp/fastlane/tests/fastlane_qyer" }
    let (:fixtures_path) { "./spec/fixtures/xcodeproj" }
    let (:proj_file) { "bundle.xcodeproj" }
    let (:pod_file) { "Podfile" }
    let (:app_suffix) { {
      'Debug' => {
        name: 'dev',
        identifier: '.debug'
        },
      'Beta' => {
        name: 'Beta',
        identifier: '.adhoc'
        },
      'RC' => {
        name: 'RC',
        identifier: ''
        },
      }
    }

    # Action parameters
    let (:xcodeproj) { File.join(test_path, proj_file) }
    let (:podfile) { File.join(test_path, pod_file) }

    before do
      # Create test folder
      FileUtils.mkdir_p(test_path)
      [proj_file, pod_file].each do |path|
        source = File.join(fixtures_path, path)
        destination = File.join(test_path, path)

        # Copy .xcodeproj fixture, as it will be modified during the test
        FileUtils.cp_r(source, destination)
      end
    end

    if FastlaneCore::Helper.mac?

      it "should raise an exception when `project_path` does not exist" do

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            xcode_bootstrap
          end").runner.execute(:test)
        end.to raise_error("Please pass the path to the project (.xcodeproj)")
      end

      it "should raise an exception when `project_path` pass wrong path" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            xcode_bootstrap({
              project_path: '/tmp/test/demo.xcodeproj'
            })
          end").runner.execute(:test)
        end.to raise_error("Could not find Xcode project")
      end

      it "works with project path and defaults settings" do
        result = Fastlane::FastFile.new.parse("lane :test do
          xcode_bootstrap({
            project_path: '#{xcodeproj}',
          })
        end").runner.execute(:test)

        expect(result).to be true
      end

      it "works with custom app suffix" do
        result = Fastlane::FastFile.new.parse("lane :test do
          xcode_bootstrap({
            project_path: '#{xcodeproj}',
            app_suffix: #{app_suffix}
          })
        end").runner.execute(:test)

        expect(result).to be true
      end

      # it "works with custom build configuration name" do
      #   stub_project = 'stub project'
      #   stub_object = 'stub object'
      #   stub_target = 'stub target'
      #   stub_target_name = 'stub_name'
      #   stub_configuration_1 = 'stub config 1'
      #   stub_configuration_2 = 'stub config 2'
      #   stub_setting_1 = 'stub setting 1'
      #
      #   expect(Xcodeproj::Project).to receive(:open).with(xcodeproj).and_return(stub_project)
      #   expect(stub_project).to receive(:objects).and_return([stub_object])
      #   expect(stub_project).to receive(:targets).and_return([stub_target])
      #   expect(stub_project).to receive(:build_configuration_list).and_return(Hash[stub_configuration_2, stub_configuration_2])
      #   expect(stub_project).to receive(:add_build_configuration).and_return(stub_configuration_1)
      #
      #   expect(stub_object).to receive(:isa).and_return('PBXFileReference')
      #   expect(stub_object).to receive(:name).and_return("pods.#{stub_configuration_1}.xcconfig")
      #
      #   expect(stub_target).to receive(:add_build_configuration).and_return(stub_configuration_1)
      #   expect(stub_target).to receive(:name).and_return(stub_target_name)
      #
      #   expect(stub_configuration_1).to receive("base_configuration_reference=")
      #   expect(stub_configuration_1).to receive(:build_settings).and_return({})
      #
      #   expect do
      #     Fastlane::FastFile.new.parse("lane :test do
      #     xcode_bootstrap({
      #       project_path: '#{xcodeproj}',
      #       build_configuration_name: '#{stub_configuration_1}',
      #       app_suffix: #{app_suffix},
      #     })
      #     end").runner.execute(:test)
      #   end.to raise_error("Build configuration `#{stub_configuration_1}` is exists, check again.")
      # end

      it "should raise an exception when app suffix is not Hash" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            xcode_bootstrap({
              project_path: '#{xcodeproj}',
              app_suffix: false,
            })
          end").runner.execute(:test)
        end.to raise_error("Invaild app suffix format. please check `fastlane action xcode_bootstrap`")
      end

      it "should raise an exception when podfile is not exist" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            xcode_bootstrap({
              project_path: '/tmp/test/demo.xcodeproj',
              cocoapods: true,
            })
          end").runner.execute(:test)
        end.to raise_error("Could not find Xcode project")
      end

      it "should raise an exception when target is empty" do
        stub_project = 'stub project'
        expect(Xcodeproj::Project).to receive(:open).with(xcodeproj).and_return(stub_project)
        expect(stub_project).to receive(:targets).and_return([])

        expect do
          Fastlane::FastFile.new.parse("lane :test do
          xcode_bootstrap({
            project_path: '#{xcodeproj}',
          })
          end").runner.execute(:test)
        end.to raise_error("Not found any target in project")
      end

      it "should raise an exception when build configuration is exist" do
        stub_project = 'stub project'
        stub_target = 'target'
        stub_target_name = 'stub_name'
        stub_configuration_1 = 'stub config 1'
        stub_configuration_2 = 'stub config 2'

        expect(Xcodeproj::Project).to receive(:open).with(xcodeproj).and_return(stub_project)
        expect(stub_project).to receive(:targets).twice.and_return([stub_target])
        expect(stub_project).to receive(:build_configuration_list).and_return(Hash[stub_configuration_1, stub_configuration_1])
        expect(stub_target).to receive(:name).and_return(stub_target_name)

        expect do
          Fastlane::FastFile.new.parse("lane :test do
          xcode_bootstrap({
            project_path: '#{xcodeproj}',
            build_configuration_name: '#{stub_configuration_1}',
          })
          end").runner.execute(:test)
        end.to raise_error("Build configuration `#{stub_configuration_1}` is exists, check again.")
      end
    end

    after do
      # Clean up files
      FileUtils.rm_r(test_path)
    end
  end
end
