require 'uri'
require 'httparty'

module Locomotive
  module Steam
    class ExternalAPIService

      include ::HTTParty

      def consume(url, options = {})
        options[:base_uri], path = extract_base_uri_and_path(url)

        options.delete(:format) if options[:format] == 'default'

        # auth ?
        username, password = options.delete(:username), options.delete(:password)
        options[:basic_auth] = { username: username, password: password } if username

        # authorization header ?
        header_auth = options.delete(:header_auth)
        options[:headers] = { 'Authorization' => header_auth } if header_auth

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
        if options[:with_user_agent]
          user_agent = { 'User-Agent' => 'LocomotiveCMS' }
          options[:headers] ? options[:headers].merge!(user_agent) : options[:headers] = user_agent
        end

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
