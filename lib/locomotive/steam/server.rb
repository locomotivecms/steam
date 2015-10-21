require 'haml'
require 'mimetype_fu'
require 'mime-types'
require 'mime/types'

require 'rack/rewrite'
require 'rack/csrf'
require 'rack/session/moneta'
require 'rack/builder'
require 'rack/lint'
require 'dragonfly/middleware'

require_relative 'middlewares'

if ENV['PROFILER']
  require 'moped'
  require 'rack-mini-profiler'
end

module Locomotive::Steam
  module Server

    class << self

      def default_middlewares
        server, configuration = self, self.configuration

        -> (stack) {
          use(Rack::Rewrite) { r301 %r{^/(.*)/$}, '/$1' }
          use Middlewares::Favicon

          if configuration.serve_assets
            use ::Rack::Static, {
              root: configuration.asset_path,
              urls: ['/images', '/fonts', '/samples', '/media', '/sites']
            }
            use Middlewares::DynamicAssets, {
              root:   configuration.asset_path,
              minify: configuration.minify_assets
            }
          end

          use Dragonfly::Middleware, :steam

          use Rack::Lint
          use Rack::Session::Moneta, configuration.moneta

          use Rack::MiniProfiler if ENV['PROFILER']

          server.steam_middleware_stack.each { |k| use k }
        }
      end

      def steam_middleware_stack
        [
          Middlewares::DefaultEnv,
          Middlewares::Site,
          Middlewares::Logging,
          Middlewares::Robots,
          Middlewares::Timezone,
          Middlewares::EntrySubmission,
          Middlewares::Locale,
          Middlewares::LocaleRedirection,
          Middlewares::Path,
          Middlewares::Page,
          Middlewares::Sitemap,
          Middlewares::TemplatizedPage
        ]
      end

      def to_app
        stack = configuration.middleware

        Rack::Builder.new do
          stack.inject(self)

          run Middlewares::Renderer.new(nil)
        end
      end

      def configuration
        Locomotive::Steam.configuration
      end

    end

  end
end
