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

    attr_reader :options

    def initialize(options = {})
      @options = prepare_options(options)
    end

    def to_app
      server = self

      Rack::Builder.new do
        use Rack::Lint

        server.serve_assets(self) if server.options[:serve_assets]

        use Middlewares::Favicon

        use Middlewares::DefaultEnv, server.options
        use Middlewares::Logging
        use Middlewares::Site
        use Middlewares::Path
        use Middlewares::Locale
        use Middlewares::Timezone
        use Middlewares::Page
        use Middlewares::TemplatizedPage

        run Middlewares::Renderer.new(nil)
      end
    end

    def prepare_options(options)
      {
        serve_assets: false,
        minify:       false,
        moneta: {
          store: Moneta.new(:Memory, expires: true)
        }
      }.merge(options)
    end

    def serve_assets(builder)
      public_path = File.join(options[:path], 'public')

      builder.use ::Rack::Static, {
        root: public_path,
        urls: ['/images', '/fonts', '/samples', '/media']
      }

      builder.use Middlewares::DynamicAssets, {
        root:   public_path,
        minify: options[:minify_assets]
      }
    end

  end
end
