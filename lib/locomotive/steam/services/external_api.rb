require 'uri'
require 'httparty'

module Locomotive
  module Steam
    module Services
      class ExternalAPI

        include ::HTTParty

        def consume(url, options = {})
          options[:base_uri], path = extract_base_uri_and_path(url)

          options.delete(:format) if options[:format] == 'default'

          # auth ?
          username, password = options.delete(:username), options.delete(:password)
          options[:basic_auth] = { username: username, password: password } if username

          perform_request_to(path, options)
        end

        private

        def extract_base_uri_and_path(url)
          url = HTTParty.normalize_base_uri(url)

          uri       = URI.parse(url)
          path      = uri.request_uri || '/'
          base_uri  = "#{uri.scheme}://#{uri.host}"
          base_uri  += ":#{uri.port}" if uri.port != 80

          [base_uri, path]
        end

        def perform_request_to(path, options)
          # [DEBUG] puts "[WebService] consuming #{path}, #{options.inspect}"

          # sanitize the options
          options[:format]  = options[:format].gsub(/[\'\"]/, '').to_sym if options.has_key?(:format)
          options[:headers] = { 'User-Agent' => 'LocomotiveCMS' } if options[:with_user_agent]

          response        = self.class.get(path, options)
          parsed_response = response.parsed_response

          if response.code == 200
            HashConverter.to_underscore parsed_response
          else
            Locomotive::Common::Logger.error "[WebService] consumed #{path}, #{options.inspect}, response = #{response.inspect}"
            nil
          end
        end

      end
    end
  end
end
