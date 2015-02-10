module Locomotive::Steam
  module Middlewares

    class DefaultEnv < Struct.new(:app, :options)

      def call(env)
        # time = Benchmark.realtime do
          request = Rack::Request.new(env)

          env['steam.request']  = request
          env['steam.services'] = Locomotive::Steam::Services.build_instance(request, options)
        # end

        # puts "[Benchmark][DefaultEnv] Time elapsed #{time*1000} milliseconds"

        app.call(env)
      end

    end

  end
end
