module Locomotive::Steam
  module Middlewares

    class DynamicAssets

      REGEXP = /^\/(javascripts|stylesheets)\/(.*)$/o

      attr_reader :app, :assets

      def initialize(app, options)
        @app    = app
        @assets = Locomotive::Steam::SprocketsEnvironment.new(options[:root], options)
      end

      def call(env)
        if env['PATH_INFO'] =~ REGEXP
          env['PATH_INFO'] = $2
          assets.call(env)
        else
          app.call(env)
        end
      end

    end

  end
end
