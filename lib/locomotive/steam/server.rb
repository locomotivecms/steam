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

        if server.options[:serve_assets]
          use ::Rack::Static, {
            root: Locomotive::Steam.configuration.assets_path,
            urls: ['/images', '/fonts', '/samples', '/media']
          }
          # use Middlewares::DynamicAssets # TODO
        end

        use Middlewares::Favicon

        use Middlewares::DefaultEnv, server.options
        use Middlewares::Logging
        use Middlewares::Site
        use Middlewares::Path
        use Middlewares::Locale
        use Middlewares::Timezone
        use Middlewares::Page

        run Middlewares::Renderer.new(nil)
      end
    end

    def prepare_options(options)
      {
        serve_assets: false,
        moneta: {
          store: Moneta.new(:Memory, expires: true)
        }
      }.merge(options)
    end

  end
end
