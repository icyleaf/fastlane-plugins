require 'spec_helper'

describe Fastlane::Actions::QyerAction do
  subject { Fastlane::Actions::QyerAction }
  it 'has a version number' do
    expect(Fastlane::Qyer::VERSION).not_to be nil
  end

  it 'has a author name' do
    expect(subject.author).to eq("icyleaf")
  end

  it 'has a details' do
    expect(subject.details).not_to be_empty
  end

  it 'has a description' do
    expect(subject.description).not_to be_empty
  end

  %w[ios android].each do |name|
    it "supports #{name} platform" do
      expect(subject.is_supported?(name.to_sym)).to be true
    end
  end

  it 'not supports mac platform' do
    expect(subject.is_supported?(:mac)).to be false
  end
end
