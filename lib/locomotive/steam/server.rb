require 'better_errors'
require 'coffee_script'

require_relative 'listen'
require_relative 'server/middleware'
require_relative 'server/favicon'
require_relative 'server/dynamic_assets'
require_relative 'server/logging'
require_relative 'server/entry_submission'
require_relative 'server/path'
require_relative 'server/locale'
require_relative 'server/page'
require_relative 'server/timezone'
require_relative 'server/templatized_page'
require_relative 'server/renderer'

require_relative 'liquid'
require_relative 'initializers'
require_relative 'monkey_patches'

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
