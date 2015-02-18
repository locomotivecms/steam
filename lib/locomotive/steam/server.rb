require 'haml'
require 'compass'
require 'mimetype_fu'
require 'mime-types'
require 'mime/types'

require 'rack/csrf'
require 'rack/session/moneta'
require 'rack/builder'
require 'rack/lint'
require 'dragonfly/middleware'

require_relative 'middlewares'

module Locomotive::Steam
  class Server

    # attr_reader :options

    # def initialize(options = {})
    #   @options = prepare_options(options)
    # end

    def to_app
      server = self

      Rack::Builder.new do
        server.serve_assets(self) if server.configuration.serve_assets

        use Middlewares::Favicon

        use Rack::Lint
        use Rack::Session::Moneta, server.configuration.moneta

        use Middlewares::DefaultEnv
        use Middlewares::Logging
        use Middlewares::Site
        use Middlewares::Timezone
        use Middlewares::EntrySubmission
        use Middlewares::Locale
        use Middlewares::Path
        use Middlewares::Page
        use Middlewares::TemplatizedPage

        run Middlewares::Renderer.new(nil)
      end
    end

    def serve_assets(builder)
      builder.use ::Rack::Static, {
        root: configuration.assets_path,
        urls: ['/images', '/fonts', '/samples', '/media']
      }

      builder.use Middlewares::DynamicAssets, {
        root:   configuration.assets_path,
        minify: configuration.minify_assets
      }
    end

    def configuration
      Locomotive::Steam.configuration
    end

    # def options

    # end

    # def prepare_options(options)
    #   {
    #     serve_assets:   false,
    #     minify_assets:  false,
    #     moneta: {
    #       store: Moneta.new(:Memory, expires: true)
    #     }
    #   }.merge(options)
    # end

  end
end
