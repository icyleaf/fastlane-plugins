describe Fastlane::Actions::GitLastCommitAction do
  describe 'Git Last Commit Integration' do
    let(:test_path) { '/tmp/fastlane/tests/fastlane_qyer' }
    let(:repo_name) { 'git_repo' }

    # Action parameters
    let(:repo_path) { File.join(test_path, repo_name) }
    let(:commiter_name) { 'king' }
    let(:commiter_email) { 'email@not.found' }
    let(:branch_name) { 'master' }
    let(:commit_subject) { 'first commit' }

    before do
      # Create test folder
      FileUtils.mkdir_p(repo_path)
      `cd #{repo_path} && git init`
      `cd #{repo_path} && git config author.name "#{commiter_name}"`
      `cd #{repo_path} && git config author.email "#{commiter_email}"`
      `cd #{repo_path} && echo "Hello World!" > README`
      `cd #{repo_path} && git add -A`
      `cd #{repo_path} && git commit -m '#{commit_subject}'`
    end

    after do
      # Clean up files
      FileUtils.rm_r(repo_path)
    end

    it 'should works with git repo project' do
      info = Fastlane::FastFile.new.parse("lane :test do
        git_last_commit({
        path: '#{repo_path}'
      })
      end").runner.execute(:test)

      expect(info[:hash]).not_to be_nil
      expect(info[:branch]).to eq('master')
      expect(info[:commiter_name]).not_to be_nil
      expect(info[:commiter_email]).not_to be_nil
      expect(info[:date]).to be_kind_of(DateTime)
      expect(info[:subject]).to eq(commit_subject)
    end

    it 'should throws an exception when root directory is not git repo' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          git_last_commit({
          path: '#{test_path}'
        })
        end").runner.execute(:test)
      end.to raise_error('Not found git repo')
    end
  end
end
