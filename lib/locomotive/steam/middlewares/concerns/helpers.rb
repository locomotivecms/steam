module Locomotive::Steam
  module Middlewares
    module Concerns
      module Helpers

        def html?
          ['text/html', 'application/x-www-form-urlencoded', 'multipart/form-data'].include?(self.request.media_type) &&
          !self.request.xhr? &&
          !self.json?
        end

        def json?
          self.request.content_type == 'application/json' || File.extname(self.request.path) == '.json'
        end

        def render_response(content, code = 200, type = nil)
          _headers = env['steam.headers'] || {}

          @next_response = [
            code,
            { 'Content-Type' => type || 'text/html' }.merge(_headers),
            [content]
          ]
        end

        def redirect_to(location, type = 301)
          _location = mounted_on && !location.starts_with?(mounted_on) && (location =~ Locomotive::Steam::IsHTTP).nil? ? "#{mounted_on}#{location}" : location

          self.log "Redirected to #{_location}".blue

          @next_response = [type, { 'Content-Type' => 'text/html', 'Location' => _location }, []]
        end

        def modify_path(path = nil, &block)
          path ||= env['steam.path']

          segments = path.split('/')
          yield(segments)
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
