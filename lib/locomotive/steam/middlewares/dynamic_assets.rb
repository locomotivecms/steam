module Locomotive::Steam
  module Middlewares

    class DynamicAssets

      REGEXP = /^\/(javascripts|stylesheets)\/(.*)$/o

      @@sprocket_environments = {}

      attr_reader :app, :assets

      def initialize(app, options)
        @app    = app
        @assets = self.class.sprocket_environment(options[:root], options)
      end

      def call(env)
        if env['PATH_INFO'] =~ REGEXP
          env['PATH_INFO'] = $2
          assets.call(env)
        else
          app.call(env)
        end
      end

      def self.sprocket_environment(root, options)
        @@sprocket_environments[root] ||= Locomotive::Steam::SprocketsEnvironment.new(root, options)
      end

    end

  end
end
