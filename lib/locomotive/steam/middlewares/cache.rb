module Locomotive::Steam
  module Middlewares

    class Cache < ThreadSafe

      include Concerns::Helpers

      CACHEABLE_RESPONSE_CODES  = [200, 301, 404, 410].freeze

      CACHEABLE_REQUEST_METHODS = %w(GET HEAD).freeze

      DEFAULT_CACHE_CONTROL     = 'max-age=0, s-maxage=3600, public, must-revalidate'.freeze

      DEFAULT_CACHE_VARY        = 'Accept-Language'.freeze

      NO_CACHE_CONTROL          = 'max-age=0, private, must-revalidate'.freeze

      def _call
        if cacheable?
          key = cache_key

          # Test if the ETag has been modified. If not, return a 304 response
          if env['If-None-Match'] == key
            render_response(nil, 304, nil)
            return
          end

          # we have to tell the CDN (or any proxy) what is the expiration / validation strategy
          env['steam.cache_control']  = cache_control
          env['steam.cache_vary']     = cache_vary
          env['steam.cache_etag']     = key

          # retrieve the response from the cache.
          # This is useful if no CDN is being used.
          code, headers, _ = fetch_cached_response(key)

          unless CACHEABLE_RESPONSE_CODES.include?(code.to_i)
            env['steam.cache_control'] = headers['Cache-Control'] = NO_CACHE_CONTROL
            env['steam.cache_vary'] = headers['Vary'] = nil
          end
        else
          env['steam.cache_control']  = NO_CACHE_CONTROL
        end
      end

      private

      def fetch_cached_response(key)
        if marshaled = cache.read(key)
          Marshal.load(marshaled)
        else
          self.next.tap do |response|
            # cache the HTML for further validations (optimization)
            cache.write(key, marshal(response))
          end
        end
      end

      def cacheable?
        CACHEABLE_REQUEST_METHODS.include?(env['REQUEST_METHOD']) &&
        !live_editing? &&
        site.try(:cache_enabled) &&
        page.try(:cache_enabled) &&
        is_redirect_url?
      end

      def cache_key
        site, path, query = env['steam.site'], env['PATH_INFO'], env['QUERY_STRING']
        key = "#{Locomotive::Steam::VERSION}/site/#{site._id}/#{site.last_modified_at.to_i}/page/#{path}/#{query}"
        Digest::MD5.hexdigest(key)
      end

      def cache_control
        site.try(:cache_control) || DEFAULT_CACHE_CONTROL
      end

      def cache_vary
        site.try(:cache_vary) || DEFAULT_CACHE_VARY
      end

      def is_redirect_url?
        return false if page.nil?
        page.try(:redirect_url).blank?
      end

      def marshal(response)
        code, headers, body = response

        # only keep string value headers
        _headers = headers.reject { |key, val| !val.respond_to?(:to_str) }

        Marshal.dump([code, _headers, body])
      end

      def cache
        services.cache
      end

    end

  end
end
