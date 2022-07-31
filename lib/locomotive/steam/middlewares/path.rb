module Locomotive::Steam
  module Middlewares

    # Sanitize the path from the previous middleware in order
    # to make it work for the renderer.
    #
    class Path

      attr_accessor_initialize :app

      def call(env)
        set_path!(env)
        app.call(env)
      end

      protected

      def set_path!(env)
        site = env['steam.site']
        path = env['steam.path'].dup

        if site.allow_dots_in_slugs
          path.gsub!(/\.(html|htm)$/, '')
        else
          path.gsub!(/\.[a-zA-Z][a-zA-Z0-9]{2,}$/, '')
        end

        path.gsub!(/^\//, '')
        path.gsub!(/^[A-Z]:\//, '')

        path = 'index' if path.blank?

        env['steam.path'] = path
      end

    end

  end
end
