describe 'Fastlane::Actions::JenkinsHelper' do

  it 'should not jenkins env' do
    ENV.delete('JENKINS_URL')
    expect(Fastlane::Actions.jenkins?).to be false
  end

  it 'should jenkins env' do
    ENV['JENKINS_URL'] = 'http://jenkins.ci'

    expect(Fastlane::Actions.jenkins?).to be true
  end
end
