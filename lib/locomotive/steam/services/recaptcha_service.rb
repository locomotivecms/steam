require 'httparty'

module Locomotive
  module Steam

    # This service supports Google Recaptcha or any API compatible with Google
    class RecaptchaService

      GOOGLE_API_URL = 'https://www.google.com/recaptcha/api/siteverify'.freeze
      MIN_SCORE = 0.2

      def initialize(site, request)
        attributes = site.metafields.values.reduce({}, :merge).with_indifferent_access

        @api       = attributes[:recaptcha_api_url] || GOOGLE_API_URL
        @secret    = attributes[:recaptcha_secret]
        @ip        = request.ip
        @min_score = attributes[:recaptcha_min_score].presence || MIN_SCORE
      end

      def verify(response_code)
        # save a HTTP query if there is no code
        return false if response_code.blank?

        _response = HTTParty.get(@api, { query: {
          secret:   @secret,
          response: response_code,
          remoteip: @ip
        }})

        body = _response.parsed_response

        return false unless body['success']

        # reCAPTCHA v2 responses don't include a score
        score = body['score']
        score.nil? || score.to_f >= @min_score.to_f
      end

    end

  end
end
