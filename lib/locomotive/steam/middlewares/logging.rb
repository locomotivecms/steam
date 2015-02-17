module Locomotive::Steam
  module Middlewares

    # Track the request into the current logger
    #
    class Logging < Struct.new(:app)

      include Helpers

      def call(env)
        now = Time.now

        log "Started #{env['REQUEST_METHOD'].upcase} \"#{env['PATH_INFO']}\" at #{now}".light_white, 0
        log "Params: #{env.fetch('steam.request').params.inspect}"

        app.call(env).tap do |response|
          done_in_ms = ((Time.now - now) * 10000).truncate / 10.0
          log "Completed #{code_to_human(response.first)} in #{done_in_ms}ms\n\n".green
        end
      end

      protected

      def code_to_human(code)
        case code.to_i
        when 200 then '200 OK'
        when 301 then '301 Found'
        when 302 then '302 Found'
        when 404 then '404 Not Found'
        when 422 then '422 Unprocessable Entity'
        end
      end

    end
  end
end
