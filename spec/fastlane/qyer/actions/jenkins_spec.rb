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
      end.to raise_error RuntimeError
    end

    it "works with ci" do
      require 'json'
      require 'date'

      ENV['JENKINS_URL'] = "http://ci.mobile.dev"
      ENV['JOB_URL'] = "#{ENV['JENKINS_URL']}/example-project"
      ENV['BUILD_NUMBER'] = '1'

      commit = {
        date: '2015-11-10 14:28:49 +0800',
        msg: '网签url update'
      }

      formatted_datetime = DateTime.parse(commit[:date]).strftime("%Y-%m-%d %H:%m")
      changelog_text = "1. #{commit[:msg]} [#{formatted_datetime}]"

      project_api_url = "#{ENV['JOB_URL']}/#{ENV['BUILD_NUMBER']}/api/json"
      stub_request(:any, project_api_url)
        .to_return(
          status: 200,
          body: JSON.generate({
            result: 'BUILDING',
            changeSet: {
              items: [
                commit
              ]
            }
          })
        )

      Fastlane::FastFile.new.parse("lane :test do
        jenkins
      end").runner.execute(:test)

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::JENKINS_CHANGLOG]).to eq(changelog_text)
      expect(ENV['JENKINS_CHANGLOG']).to eq(changelog_text)
    end

    it 'will force build' do
      ENV['GIT_PREVIOUS_SUCCESSFUL_COMMIT'] = ENV['GIT_COMMIT'] = 'aa8984bc4e19b49f55c9b6f3a1e7b1011b38d55e'
    end
  end
end
