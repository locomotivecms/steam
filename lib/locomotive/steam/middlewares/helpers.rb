module Locomotive::Steam
  module Middlewares

    module Helpers

      def html?
        ['text/html', 'application/x-www-form-urlencoded'].include?(self.request.media_type) &&
        !self.request.xhr? &&
        !self.json?
      end

      def json?
        self.request.content_type == 'application/json' || File.extname(self.request.path) == '.json'
      end

      def render_response(content, code = 200, type = 'text/html')
        @next_response = [code, { 'Content-Type' => type }, [content]]
      end

      def redirect_to(location, type = 301)
        _location = mounted_on && (location =~ Steam::IsHTTP).nil? ? "#{mounted_on}#{location}" : location

        self.log "Redirected to #{_location}".blue

        @next_response = [type, { 'Content-Type' => 'text/html', 'Location' => _location }, []]
      end

      def modify_path(path = nil, &block)
        path ||= request.path

        segments = path.split('/')
        yield(segments)
        path = segments.join('/')

        path = '/' if path.blank?
        path += "?#{request.query_string}" unless request.query_string.empty?
        path
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
