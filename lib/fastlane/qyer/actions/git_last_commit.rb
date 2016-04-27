require 'date'

module Fastlane
  module Actions
    module SharedValues
      GIT_LAST_COMMIT_HASH = :GIT_LAST_COMMIT_HASH
      GIT_LAST_COMMIT_BRANCH_NAME = :GIT_LAST_COMMIT_BRANCH_NAME
      GIT_LAST_COMMIT_COMMITER_NAME = :GIT_LAST_COMMIT_COMMITER_NAME
      GIT_LAST_COMMIT_COMMITER_EMAIL = :GIT_LAST_COMMIT_COMMITER_EMAIL
      GIT_LAST_COMMIT_DATE = :GIT_LAST_COMMIT_DATE
      GIT_LAST_COMMIT_SUBJECT = :GIT_LAST_COMMIT_SUBJECT
    end
    ##
    # Git Last Commit
    class GitLastCommitAction < Action
      def self.run(params)
        @project_path = params[:path] || File.read_path('.')
        UI.user_error!('Not found git repo') unless git_repo?

        dump_to_env

        {
          hash: hash,
          subject: subject,
          branch: branch_name,
          commiter_name: commiter_name,
          commiter_email: commiter_email,
          date: date
        }
      end

      def self.dump_to_env
        output.each do |item|
          env_name = item[0]
          value = send(env_name.gsub('GIT_LAST_COMMIT_', '').downcase)
          Actions.lane_context[SharedValues.const_get(env_name)] = value
        end
      end

      def self.hash
        run_sh('git rev-parse --short HEAD')
      end

      def self.date
        DateTime.parse(run_sh('git log -1 --format=%ci'))
      end

      def self.subject
        run_sh('git log -1 --format=%s')
      end

      def self.branch_name
        run_sh('git rev-parse --abbrev-ref HEAD')
      end

      def self.commiter_name
        run_sh('git log -1 --format=%cn')
      end

      def self.commiter_email
        run_sh('git log -1 --format=%ce')
      end

      def self.git_repo?
        Dir.exist?(File.join(@project_path, '.git'))
      end

      def self.run_sh(command)
        commands = ["cd #{@project_path}", '&&', command]
        Actions.sh(commands.join(' '), log: false).strip
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
          ['GIT_LAST_COMMIT_COMMITER_NAME', 'The commiter name of git last commit'],
          ['GIT_LAST_COMMIT_COMMITER_EMAIL', 'The commiter email of git last commit'],
          ['GIT_LAST_COMMIT_DATE', 'The date of git last commit'],
          ['GIT_LAST_COMMIT_SUBJECT', 'The subject of git last commit']
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
