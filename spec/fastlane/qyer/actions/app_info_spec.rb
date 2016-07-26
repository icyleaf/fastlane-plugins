describe Fastlane::Actions::AppInfoAction do
  describe 'App Info Integration' do
    it 'should throws an exception if not pass ipa or apk file' do
      expect do
        Fastlane::FastFile.new.parse('lane :test do
            app_info
          end').runner.execute(:test)
      end.to raise_error('You have to either pass an ipa or an apk file')
    end
  end
end