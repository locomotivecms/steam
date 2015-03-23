module Locomotive::Steam
  module Middlewares

    class Robots < Struct.new(:app, :options)

      include Helpers

      def call(env)
        if env['PATH_INFO'] == '/robots.txt'
          site = env['steam.site']
          render_response(site[:robots_txt] || '', 200, 'text/plain')
        else
          app.call(env)
        end
      end

    end

  end
end
