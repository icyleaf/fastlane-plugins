module Fastlane
  module Actions
    class GitRemotesAction < Action
      def self.run(_)
        `git remote 2>/dev/null`.strip.split("\n")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Returns the names of the git remote.'
      end

      def self.category
        :source_control
      end

      def self.authors
        ['icyleaf']
      end

      def self.return_type
        :array
      end

      def self.is_supported?(_)
        true
      end
    end
  end
end
