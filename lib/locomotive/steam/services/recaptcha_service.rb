require 'httparty'

module Locomotive
  module Steam

    # This service supports Google Recaptcha or any API compatible with Google
    class RecaptchaService

      GOOGLE_API_URL = 'https://www.google.com/recaptcha/api/siteverify'.freeze

      def initialize(site, request)
        @api      = site.metafields.dig(:google, :recaptcha_api_url) || GOOGLE_API_URL
        @secret   = site.metafields.dig(:google, :recaptcha_secret)
        @ip       = request.ip
      end

      def verify(response_code)
        puts "VERIFY!!! #{response_code.inspect}"

        # save a HTTP query if there is no code
        return false if response_code.blank?

        _response = HTTParty.get(@api, { query: {
          secret:   @secret,
          response: response_code,
          remoteip: @ip
        }})

        puts "@api = #{@api}, #{@secret}, #{response_code}, result = #{_response.parsed_response.inspect}"

        _response.parsed_response['success']
      end

    end

  end
end
