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
    let (:test_path) { "/tmp/fastlane/tests/fastlane" }
    let (:fixtures_path) { "./spec/fixtures/xcodeproj" }
    let (:proj_file) { "bundle.xcodeproj" }
    let (:pod_file) { "Podfile" }
    let (:app_suffix) { {
      'Debug': {
        name: 'dev',
        identifier: '.debug'
        },
      'Beta': {
        name: 'Beta',
        identifier: '.adhoc'
        },
      'RC': {
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
      source = File.join(fixtures_path, proj_file)
      destination = File.join(test_path, proj_file)

      # Copy .xcodeproj fixture, as it will be modified during the test
      FileUtils.cp_r(source, destination)
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
        result = Fastlane::FastFile.new.parse("lane :bootstrap do
          xcode_bootstrap({
            project_path: '#{xcodeproj}',
          })
        end").runner.execute(:bootstrap)

        expect(result).to be true
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

      # it "should" do
      #   stub_project = 'stub project'
      #   stub_configuration = 'stub config'
      #   stub_object = ['object']
      #
      #   expect(Xcodeproj::Project).to receive(:open).with('/tmp/fastlane/tests/fastlane/bundle.xcodeproj').and_return(stub_project)
      #   expect(stub_project).to receive(:objects).and_return(stub_object)
      #   expect(stub_object).to receive(:select).and_return([])
      #
      #   create_plist_with_identifier("$(#{identifier_key})")
      #   expect do
      #     Fastlane::FastFile.new.parse("lane :test do
      #     update_app_identifier({
      #       xcodeproj: '#{xcodeproj}',
      #       plist_path: '#{plist_path}',
      #       app_identifier: '#{app_identifier}'
      #     })
      #     end").runner.execute(:test)
      #   end.to raise_error("Info plist uses $(#{identifier_key}), but xcodeproj does not")
      # end


    end

    after do
      # Clean up files
      FileUtils.rm_r(test_path)
    end
  end
end
