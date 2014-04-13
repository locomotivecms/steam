module Locomotive::Steam
  module Middlewares

    class Favicon < Base

      def call(env)
        if env['PATH_INFO'] == '/favicon.ico'
          [200, { 'Content-Type' => 'image/vnd.microsoft.icon' }, ['']]
        else
          app.call(env)
        end
      end

    end

  end
end