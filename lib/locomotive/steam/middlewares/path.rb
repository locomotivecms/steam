module Locomotive::Steam
  module Middlewares

    # Sanitize the path from the previous middleware in order
    # to make it work for the renderer.
    #
    class Path < Base

      def _call(env)
        super

        self.set_path!(env)

        app.call(env)
      end

      protected

      def set_path!(env)
        path = env['PATH_INFO'].clone

        path.gsub!(/\.[a-zA-Z][a-zA-Z0-9]{2,}$/, '')
        path.gsub!(/^\//, '')
        path.gsub!(/^[A-Z]:\//, '')

        path = 'index' if path.blank?

        env['steam.path'] = path
      end

    end

  end
end