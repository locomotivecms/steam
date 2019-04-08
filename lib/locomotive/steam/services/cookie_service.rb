module Locomotive
  module Steam

    class CookieService

      def initialize(request)
        @request = request
        @cookies = request.env['steam.cookies']
      end

      def set(key, vals)
        @cookies[key] = vals
      end

      def get(key)
        if @cookies.include?(key)
          @cookies[key]['value']
        else
          @request.cookies[key]
        end
      end

    end
  end
end
