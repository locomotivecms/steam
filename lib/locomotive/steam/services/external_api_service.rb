require 'uri'
require 'httparty'

module Locomotive
  module Steam
    class ExternalAPIService

      include ::HTTParty

      # any HTTP call shouldn't block a thread or a process
      # for a long time (waiting for 3 seconds seems reasonable).
      open_timeout 3
      read_timeout 3

      # Available option keys:
      # - method
      # - data
      # - format
      # - username / password (basic auth)
      # - headers
      # - header_auth
      # - with_user_agent
      #
      def consume(url, options = {}, with_status = false)
        base_uri, path = extract_base_uri_and_path(url)

        method = (options[:method] || 'GET').to_s.downcase

        _options = build_httpparty_options(options, method)
        _options[:base_uri] = base_uri

        if with_status
          verbose_perform_request_to(method, path, _options)
        else
          perform_request_to(method, path, _options)
        end
      end

      private

      def build_httpparty_options(options, method)
        _options = {}

        # data: body (POST/PUT/PATCH) or query (GET)
        _options[method == 'get' ? :query : :body] = options[:data] if options[:data]

        # basic auth?
        username, password = options[:username], options[:password]
        _options[:basic_auth] = { username: username, password: password } if username

        # headers
        _options[:headers] = options[:headers] || {}
        _options[:headers]['Authorization'] = options[:header_auth] if options[:header_auth]
        _options[:headers]['User-Agent'] = 'LocomotiveCMS' if options[:with_user_agent]
        _options.delete(:headers) if _options[:headers].blank?

        # format
        if options.has_key?(:format) && options[:format] != 'default'
          _options[:format] = options[:format].gsub(/[\'\"]/, '').to_sym
        end

        _options
      end

      def extract_base_uri_and_path(url)
        url = HTTParty.normalize_base_uri(url)

        uri       = URI.parse(url)
        path      = uri.request_uri || '/'
        base_uri  = "#{uri.scheme}://#{uri.host}"
        base_uri  += ":#{uri.port}" if (uri.port != 80 && uri.port != 443)

        [base_uri, path]
      end

      def perform_request_to(method, path, options)
        response        = self.class.send(method.to_sym, path, options)
        parsed_response = response.parsed_response

        if response.code == 200
          HashConverter.to_underscore(parsed_response)
        else
          Locomotive::Common::Logger.error "[WebService] consumed [#{method.to_s.upcase}] #{path}, #{options.inspect}, response = #{response.inspect}"
          nil
        end
      end

      def verbose_perform_request_to(method, path, options)
        response        = self.class.send(method.to_sym, path, options)
        parsed_response = response.parsed_response
        {
          status: response.code,
          data:   HashConverter.to_underscore(parsed_response)
        }
      rescue Exception => e
        { status: nil, error: e.message }
      end

    end
  end
end
