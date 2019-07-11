module Locomotive::Steam
  module Middlewares
    module Concerns
      module Helpers

        HTML_CONTENT_TYPE = 'text/html'.freeze

        HTML_MIME_TYPES   = [nil, 'text/html', 'application/x-www-form-urlencoded', 'multipart/form-data'].freeze

        def html?
          HTML_MIME_TYPES.include?(self.request.media_type) &&
          !self.request.xhr? &&
          !self.json?
        end

        def json?
          self.request.content_type == 'application/json' || File.extname(self.request.path) == '.json'
        end

        def render_response(content, code = 200, type = nil)
          base_headers = { 'Content-Type' => type || HTML_CONTENT_TYPE }

          base_headers['Cache-Control'] = env['steam.cache_control'] if env['steam.cache_control']
          base_headers['ETag'] = env['steam.cache_etag'] if env['steam.cache_etag']
          base_headers['Vary'] = env['steam.cache_vary'] if env['steam.cache_vary']

          _headers = env['steam.headers'] || {}
          inject_cookies(_headers)

          @next_response = [code, base_headers.merge(_headers), [content]]
        end

        def redirect_to(location, type = 301)
          _location = mounted_on && !location.starts_with?(mounted_on) && (location =~ Locomotive::Steam::IsHTTP).nil? ? "#{mounted_on}#{location}" : location

          self.log "Redirected to #{_location}".blue

          headers = { 'Content-Type' => HTML_CONTENT_TYPE, 'Location' => _location }
          inject_cookies(headers)

          @next_response = [type, headers, []]
        end

        def inject_cookies(headers)
          _cookies = env['steam.cookies'] || {}
          _cookies.each do |key, vals|
            Rack::Utils.set_cookie_header!(headers, key, vals.symbolize_keys!)
          end
        end

        def modify_path(path = nil, &block)
          path ||= env['steam.path']

          segments = path.split('/')
          yield(segments) if block_given?
          path = segments.join('/')

          path = '/' if path.blank?
          path += "?#{request.query_string}" unless request.query_string.empty?
          path
        end

        # make sure the location passed in parameter doesn't
        # include the "mounted_on" parameter.
        # If so, returns the location without the "mounted_on" string.
        def make_local_path(location)
          return location if mounted_on.blank?
          location.gsub(Regexp.new('^' + mounted_on), '')
        end

        def mounted_on
          request.env['steam.mounted_on']
        end

        def log(msg, offset = 2)
          Locomotive::Common::Logger.info (' ' * offset) + msg
        end

      end
    end
  end
end
