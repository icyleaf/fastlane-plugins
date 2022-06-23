module Fastlane
  module Actions
    class RunTimeAction < Action
      VERSION = '0.1.0'.freeze

      def self.run(params)
        filters = params[:filters]
        filters = filters.split(',').map(&:chomp) if filters.is_a?(String)

        report = generate_report(console_text, filters)
        print_table(report, params[:keep_cost_time])
      end

      def self.print_table(report, keep_cost_time)
        rows = report.sort_by { |l| -l[:time] }.each_with_object([]) do |line, obj|
          time = line[:time]
          next unless (value = keep_cost_time) && time >= value.to_f

          message = line[:message]
          obj << ["#{time}s", message]
        end

        puts Terminal::Table.new(
          title: "Report for run_time #{VERSION}".green,
          headings: ['Time', 'Message'],
          rows: rows
        )
      end

      def self.generate_report(text, filters)
        [].tap do |obj|
          previous_message = nil
          start_time = nil

          text.each_line do |line|
            next unless line.start_with?('INFO')
            next if filters &.select { |s| line.include?(s) } &.empty?

            line = line.gsub(/\[[\d|;]+m/, '').gsub('▸', '').gsub('', '')
            prefix, message = line.split(']: ')
            message = message.strip
            next if message == '^'

            timestamp_start = prefix.index('[') + 1
            timestamp_end = prefix.index(']')
            timestamp = Time.parse(prefix[timestamp_start..timestamp_end], '%Y-%m-%d %H:%M:%S.%2N')

            previous_message = message
            if start_time.nil?
              start_time = timestamp.to_f
              next
            end

            time = timestamp.to_f - start_time
            obj << {
              message: previous_message,
              started: timestamp,
              time: time.round(2)
            }
            start_time = nil
          end
        end
      end

      def self.console_text
        require 'uri'
        require 'faraday'
        require 'faraday_middleware'

        uri = URI.parse(ENV['BUILD_URL'])
        url_path = File.join(uri.path, 'consoleText')
        uri.path = ''

        connection = Faraday.new(url: uri.to_s) do |builder|
          builder.request(:retry, max: 3, interval: 5)
          builder.use(FaradayMiddleware::FollowRedirects)
          builder.adapter(:net_http)
        end

        begin
          connection.get do |req|
            req.url(url_path)
          end.body.force_encoding('UTF-8')
        rescue Faraday::Error::TimeoutError
          show_error('Uploading build to Pgyer timed out ⏳', fail_on_error)
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Returns the names of the git remote.'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :filters,
                                       env_name: 'RUN_TIME_FILTERS',
                                       description: 'The endpoint of apphost',
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :keep_cost_time,
                                       env_name: 'RUN_TIME_FILTERS',
                                       description: 'The endpoint of apphost',
                                       optional: true,
                                       default_value: 1,
                                       type: Integer)
        ]
      end

      def self.category
        :misc
      end

      def self.authors
        ['icyleaf']
      end

      def self.is_supported?(_)
        true
      end
    end
  end
end
