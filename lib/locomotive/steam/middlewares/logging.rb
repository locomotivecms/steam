module Locomotive::Steam
  module Middlewares

    # Track the request into the current logger
    #
    class Logging

      include Concerns::Helpers

      attr_accessor_initialize :app

      def call(env)
        now = Time.now

        log "Started #{env['REQUEST_METHOD'].upcase} \"#{env['PATH_INFO']}\" at #{now}".light_white, 0

        debug_log "Params: #{env.fetch('steam.request').params.inspect}"
        
        app.call(env).tap do |response|
          done_in_ms = ((Time.now - now) * 10000).truncate / 10.0
          log "Completed #{code_to_human(response.first)} in #{done_in_ms}ms\n\n".green

          ActiveSupport::Notifications.instrument('steam.http.render', {
            site_id: env['steam.site']&._id,
            domain: env['SERVER_NAME'],
            path: env['PATH_INFO'],
            status: response.first,
            time_in_ms: done_in_ms
          })
        end
      end

      protected

      def code_to_human(code)
        case code.to_i
        when 200 then '200 OK'
        when 301 then '301 Found'
        when 302 then '302 Found'
        when 304 then '304 Not Modified'
        when 404 then '404 Not Found'
        when 422 then '422 Unprocessable Entity'
        end
      end

    end
  end
end
