module Locomotive::Steam
  module Middlewares

    class DefaultEnv < Struct.new(:app, :options)

      def call(env)
        request = Rack::Request.new(env)

        env['steam.request']  = request
        env['steam.services'] = Locomotive::Steam::Services.build_instance(request, options)

        app.call(env)
      end

    end

  end
end
