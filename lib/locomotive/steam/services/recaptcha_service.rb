require 'httparty'

module Locomotive
  module Steam

    class RecaptchaService

      def initialize(request, site)
        # This service support google recaptcha or API compatible
        @api = site.metafields.dig(:google, :recaptcha_api) || 'https://www.google.com/recaptcha/api/siteverify'
        @secret = site.metafields.dig(:google, :recaptcha_secret)
        @request = request
      end

      def verify(response)
        res = HTTParty.get(@api, { query: {
            secret: @secret,
            response: response,
            remoteip: @request.ip,
        }})
        res.parsed_response["success"]
      end

    end

  end
end
