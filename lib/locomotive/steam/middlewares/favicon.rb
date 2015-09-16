module Locomotive::Steam
  module Middlewares

    class Favicon

      attr_accessor_initialize :app

      include Helpers

      def call(env)
        if env['PATH_INFO'] == '/favicon.ico'
          # Default and empty Favicon rendered
          [200, { 'Content-Type' => 'image/vnd.microsoft.icon' }, ['']]
        else
          app.call(env)
        end
      end

    end

  end
end
