module Fastlane
  module Actions
    class ServiceHealthAction < Action
      VERSION = '0.1.0'.freeze

      def self.run(params)
        print_table(params)

        messages = []
        if params[:name]
          messages << "[#{params[:name]}]"
        else
          messages << "[#{URI.parse(params[:url]).host}]"
        end

        begin
          response = request(params)
          handle_reponse(response, params[:accepted_status_codes])

          code = response.status
          # code_message = Net::HTTPResponse::CODE_TO_OBJ[code.to_s]

          messages << "[✅ 服务正常] #{code}"
          UI.success(messages.join(' '))
          UI.verbose(response.body)

          true
        rescue Faraday::SSLError, Faraday::ConnectionFailed => exception
          messages << "[🌐 网络问题] - #{exception.class} - #{exception.message}"
          message = messages.join(' ')
          UI.crash!(message)
        rescue Faraday::ClientError => exception
          messages << "[🟡 服务异常] - #{exception.class} - #{exception.message}"
          message = messages.join(' ')
          UI.crash!(message)
        rescue => exception
          messages << "[🔴 服务宕机] - #{exception.class} - #{exception.message}"
          message = messages.join(' ')
          UI.crash!(message)
        end
      end

      def self.request(params)
        connection = build_connection(params)
        connection.run_request(params[:method], '', params[:body], params[:headers]) do |req|
          req.options.timeout = params[:timeout] if params[:timeout]
        end
      end

      def self.build_connection(params)
        require 'faraday'
        require 'faraday_middleware'

        connection = Faraday.new(url: params[:url]) do |builder|
          # builder.request(:url_encoded)
          # builder.request(:retry, max: 3, interval: 5)
          # builder.response(:json, content_type: /\bjson$/)
          # builder.use(FaradayMiddleware::FollowRedirects)

          builder.response(:logger, nil, {bodies: true, log_level: :debug}) if params[:enable_request_logger]
          builder.adapter(Faraday.default_adapter)
        end
      end
      private_class_method :build_connection

      def self.handle_reponse(response, accepted_status_codes)
        codes = flatten_array(accepted_status_codes)
        unless codes.include?(response.status)
          raise "状态码没有正确匹配: #{response.status}"
        end

        true
      end

      def self.print_table(form)
        rows = form.all_keys.each_with_object({}) do |key, obj|
                 next if form[key].to_s.empty?

                 obj[key] = form[key]
               end

        # rows[:client] = "Faraday v#{Faraday::VERSION}"
        puts Terminal::Table.new(
          title: "Summary for service health #{VERSION}".green,
          rows: rows
        )
      end

      def self.flatten_array(codes)
        codes.each_with_object([]) do |code, obj|
          case code
          when Array
            obj.concat(code)
          when Range
            obj.concat(code.to_a)
          when Integer
            obj << code
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Service health check'
      end

      #  sh "curl --form plat_id=#{plat_id} --form file_nick_name=#{app_name} --form token=a83c617952d0a6129616d0d307ab840e841935d7 --form file=@#{file} https://app.haohaozhu.me/api/pkgs"
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: 'SERVICE_HEALTH_URL',
                                       description: 'The url of service',
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: 'SERVICE_HEALTH_URL',
                                       description: 'The name of service',
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :timeout,
                                       env_name: 'SERVICE_HEALTH_TIMEOUT',
                                       description: 'The timeout of request url',
                                       default_value: 30,
                                       type: Integer,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :method,
                                       env_name: 'SERVICE_HEALTH_METHOD',
                                       description: 'The method of url',
                                       default_value: :get,
                                       type: Symbol,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("method must be #{Faraday::Connection::METHODS.to_a.join(', ')}") unless Faraday::Connection::METHODS.include?(value)
                                       end
                                       ),
          FastlaneCore::ConfigItem.new(key: :accepted_status_codes,
                                       env_name: 'SERVICE_HEALTH_ACCEPTED_STATUS_CODES',
                                       description: 'Accepted status codes of url response',
                                       default_value: [200..299],
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :headers,
                                       env_name: 'SERVICE_HEALTH_HEADERS',
                                       description: 'The headers of request url',
                                       type: Hash,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :body,
                                       env_name: 'SERVICE_HEALTH_BODY',
                                       description: 'The body of request url',
                                       type: String,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :enable_request_logger,
                                       env_name: 'SERVICE_HEALTH_ENABLE_REAUEST_LOGGER',
                                       description: 'Enable request logger by using Faraday (true/false)',
                                       optional: true,
                                       default_value: false,
                                       type: Boolean)
        ]
      end

      def self.example_code
        [
          'service_health(
            url: "...",
            method: :get,
            query: "",
            headers: {},
            body: {},
            retries: 0,
            timeout: 10,
            accept_status_codes: [200, 201, 202, 203, 204, 205, 206, 207, 208, 226],
          )'
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
