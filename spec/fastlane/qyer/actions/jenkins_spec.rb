require 'spec_helper'

describe Fastlane::Actions::JenkinsAction do
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
