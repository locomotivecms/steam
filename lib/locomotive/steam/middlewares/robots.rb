module Locomotive::Steam
  module Middlewares

    class Robots < ThreadSafe

      include Concerns::Helpers

      def _call
        if env['PATH_INFO'] == '/robots.txt'
          site = env['steam.site']
          render_response(site[:robots_txt] || '', 200, 'text/plain')
        else
          self.next
        end
      end

    end

  end
end
