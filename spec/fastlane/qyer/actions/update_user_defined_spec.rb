describe Fastlane::Actions::UpdateUserDefinedAction do
  describe 'Xcode bootstrap Integration' do
    let (:test_path) { '/tmp/fastlane/tests/fastlane_qyer' }
    let (:fixtures_path) { './spec/fixtures/xcodeproj' }
    let (:proj_file) { 'bundle.xcodeproj' }

    # Action parameters
    let (:xcodeproj) { File.join(test_path, proj_file) }

    before do
      # Create test folder
      FileUtils.mkdir_p(test_path)
      source = File.join(fixtures_path, proj_file)
      destination = File.join(test_path, proj_file)

      # Copy .xcodeproj fixture, as it will be modified during the test
      FileUtils.cp_r(source, destination)
    end

    after do
      # Clean up files
      FileUtils.rm_r(test_path)
    end

    it 'update all build confiurations with key and value' do
      name = 'stub_name'
      value = 'stub_value'

      Fastlane::FastFile.new.parse("lane :test do
        update_user_defined({
        project_path: '#{xcodeproj}',
        name: '#{name}',
        value: '#{value}'
      })
      end").runner.execute(:test)

      helper = Fastlane::Qyer::Helper::XcodeHelper.new(xcodeproj)
      helper.target(0).build_configurations.each do |c|
        expect(c.build_settings.key?(name)).to be true
        expect(c.build_settings[name]).to eq value
      end
    end

    it 'only update build confiurations with `Release`' do
      name = 'ReleaseKey'
      value = 'ReleaseValue'
      configuration = 'Release'

      Fastlane::FastFile.new.parse("lane :test do
        update_user_defined({
        project_path: '#{xcodeproj}',
        name: '#{name}',
        value: '#{value}',
        configuration: '#{configuration}'
      })
      end").runner.execute(:test)

      helper = Fastlane::Qyer::Helper::XcodeHelper.new(xcodeproj)
      helper.target(0).build_configurations.each do |c|
        if c.name == configuration
          expect(c.build_settings.key?(name)).to be true
          expect(c.build_settings[name]).to eq value
        else
          expect(c.build_settings.key?(name)).to be false
        end
      end
    end
  end
end
