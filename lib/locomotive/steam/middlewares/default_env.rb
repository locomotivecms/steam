module Locomotive::Steam
  module Middlewares

    class DefaultEnv

      attr_accessor_initialize :app

      def call(env)
        request = Rack::Request.new(env)

        env['steam.request']        = request
        env['steam.services']       = build_services(request)
        env['steam.liquid_assigns'] = {}

        app.call(env)
      end

      private

      def build_services(request)
        Locomotive::Steam::Services.build_instance(request)
      end

    end

  end
end
