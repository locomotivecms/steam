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
        self.log "Redirected to #{location}".blue
        @next_response = [type, { 'Content-Type' => 'text/html', 'Location' => location }, []]
      end

      def log(msg)
        Locomotive::Common::Logger.info msg
      end

    end

  end
end
