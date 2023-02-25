module Locomotive::Steam
  module Middlewares

    class Favicon

      attr_accessor_initialize :app

      include Concerns::Helpers

      def call(env)
        if env['PATH_INFO'] == '/favicon.ico'
          # Default and empty Favicon rendered
          [200, { 'content-type' => 'image/vnd.microsoft.icon' }, ['']]
        else
          app.call(env)
        end
      end

    end

  end
end
