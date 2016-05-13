describe Fastlane::Actions::QyerAction do
  describe 'Information' do
    subject { Fastlane::Actions::QyerAction }
    it 'has a author name' do
      expect(subject.author).to eq('icyleaf')
    end

    it 'has a details' do
      expect(subject.details).not_to be_empty
    end

    it 'has a description' do
      expect(subject.description).not_to be_empty
    end

    %w(ios android).each do |name|
      it 'supports #{name} platform' do
        expect(subject.is_supported?(name.to_sym)).to be true
      end
    end

    it 'not supports mac platform' do
      expect(subject.is_supported?(:mac)).to be false
    end
  end

  describe 'Qyer Integration' do
    it 'should throws an exception if not pass ipa or apk file' do
      ENV['QYER_API_KEY'] = 'test'
      expect do
        Fastlane::FastFile.new.parse('lane :test do
            qyer
          end').runner.execute(:test)
      end.to raise_error('You have to either pass an ipa or an apk file')
    end

    it 'should works an exception if not pass ipa or apk file' do
      file = '/Users/wiiseer/Downloads/ipQYER_6.9.1_05121806_201605121910.ipa'
      allow(File).to receive(:exist?).and_call_original
      # allow(File).to receive(:exist?).with(file).and_return(true)

      ENV['QYER_GIT_BRANCH'] = 'develop'
      result = Fastlane::FastFile.new.parse("lane :test do
          qyer(
            api_key: '75f4d21a3d4efbd9ba9217eb6989a35b',
            ipa: '#{file}'
          )
        end").runner.execute(:test)

      expect(result).to eq('') # raise_error("Couldn't find ipa file")
    end
  end
end
