require 'date'

module Fastlane
  module Actions
    ##
    # Git Last Commit
    class GitLastCommitAction < Action
      def self.run(params)
        @project_path = params[:path] || File.read_path('.')
        return unless git_repo?

        {
          hash: commit_hash,
          branch: branch_name,
          author_name: author_name,
          author_email: author_email,
          date: commit_date
        }
      end

      def self.commit_hash
        `git rev-parse --short HEAD`
      end

      def self.branch_name
        `git rev-parse --abbrev-ref HEAD`
      end

      def self.author_name
        `git log -1 --format=%an`
      end

      def self.author_email
        `git log -1 --format=%ae`
      end

      def self.commit_date
        DateTime.parse(`git log -1 --format=%ci`)
      end

      def self.git_repo?
        Dir.exist?@project_path
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: 'GIT_LAST_COMMIT_PATH',
                                       description: 'The root directory of the git repo. Defaults to `.`',
                                       default_value: '.')
        ]
      end

      def self.description
        'Get the informations from git last commit'
      end

      def self.author
        'icyleaf'
      end

      def self.output
        [
          ['GIT_LAST_COMMIT_HASH', 'The hash of git last commit'],
          ['GIT_LAST_COMMIT_BRANCH_NAME', 'The branch name of git last commit'],
          ['GIT_LAST_COMMIT_AUTHOR_NAME', 'The author name of git last commit'],
          ['GIT_LAST_COMMIT_AUTHOR_EMAIL', 'The author email of git last commit'],
          ['GIT_LAST_COMMIT_DATE', 'The date of git last commit'],
          ['GIT_LAST_COMMIT_MESSAGE', 'The message of git last commit']
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
