require 'spec_helper'

describe Fastlane::Actions::JenkinsAction do

  describe 'Information' do
    subject { Fastlane::Actions::JenkinsAction }

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
  end

  describe "Jenkins Integration" do
    it "not works with non-ci" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          jenkins
        end").runner.execute(:test)
      end.to raise_error
    end

    it "works with ci" do
      ENV['JENKINS_URL'] = "http://jenkins"
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          jenkins
        end").runner.execute(:test)
      end.to raise_error
    end

    it 'will force build' do
      ENV['GIT_PREVIOUS_SUCCESSFUL_COMMIT'] = ENV['GIT_COMMIT'] = 'aa8984bc4e19b49f55c9b6f3a1e7b1011b38d55e'
    end
  end
end
