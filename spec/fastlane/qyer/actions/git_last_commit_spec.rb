describe Fastlane::Actions::GitLastCommitAction do
  describe 'Git Last Commit Integration' do
    let(:test_path) { '/tmp/fastlane/tests/fastlane_qyer' }
    let(:repo_name) { 'git_repo' }

    # Action parameters
    let(:repo_path) { File.join(test_path, repo_name) }

    before do
      # Create test folder
      FileUtils.mkdir_p(repo_path)
      `cd #{repo_path} && git init`
      `touch README`
      `git add -A && git commit -m 'first commit'`
    end

    after do
      # Clean up files
      FileUtils.rm_r(repo_path)
    end

    it 'should works with git repo project' do
      ap Fastlane::FastFile.new.parse("lane :test do
        git_last_commit({
        path: '#{repo_path}'
      })
      end").runner.execute(:test)
    end
  end
end
