require 'better_errors'
require 'coffee_script'

require 'locomotive/steam/listen'
require 'locomotive/steam/server/middleware'
require 'locomotive/steam/server/favicon'
require 'locomotive/steam/server/dynamic_assets'
require 'locomotive/steam/server/logging'
require 'locomotive/steam/server/entry_submission'
require 'locomotive/steam/server/path'
require 'locomotive/steam/server/locale'
require 'locomotive/steam/server/page'
require 'locomotive/steam/server/timezone'
require 'locomotive/steam/server/templatized_page'
require 'locomotive/steam/server/renderer'

require 'locomotive/steam/liquid'
require 'locomotive/steam/misc'

module Locomotive::Steam
  class Server

    def initialize(reader, options = {})
      Locomotive::Steam::Dragonfly.setup!(reader.mounting_point.path)

      Sprockets::Sass.add_sass_functions = false

      @reader = reader
      @app    = self.create_rack_app(@reader)

      BetterErrors.application_root = reader.mounting_point.path
    end

    def call(env)
      env['steam.mounting_point'] = @reader.mounting_point
      @app.call(env)
    end

    protected

    def create_rack_app(reader)
      Rack::Builder.new do
        use Rack::Lint

        use BetterErrors::MiddlewareWrapper

        use Rack::Session::Cookie, {
          key:          'steam.session',
          path:         '/',
          expire_after: 2592000,
          secret:       'uselessinlocal'
        }

        use ::Dragonfly::Middleware, :images

        use Rack::Static, {
          urls: ['/images', '/fonts', '/samples', '/media'],
          root: File.join(reader.mounting_point.path, 'public')
        }

        use Favicon
        use DynamicAssets, reader.mounting_point.path

        use Logging

        use EntrySubmission

        use Path
        use Locale
        use Timezone

        use Page
        use TemplatizedPage

        run Renderer.new
      end
    end

  end
end
