require 'coffee_script'

module Locomotive::Steam
  module Middlewares

    class DynamicAssets # < Base

      attr_reader :app, :regexp

      def initialize(app)
        @regexp = /^\/(javascripts|stylesheets)\/(.*)$/o
      end

      def call(env)
        app.call(env)
        # _call(env)
        # dup._call(env) # thread-safe purpose
      end

      def _call(env)
        if env['PATH_INFO'] =~ self.regexp
          env['PATH_INFO'] = $2

          # base_path = env['steam.mounting_point'].path

          # begin
          #   sprockets = Locomotive::Mounter::Extensions::Sprockets.environment(base_path)
          #   sprockets.call(env)
          # rescue Exception => e
          #   raise Locomotive::Steam::DefaultException.new "Unable to serve a dynamic asset. Please check the logs.", e
          # end
        else
          app.call(env)
        end
      end

    end

  end
end
