require 'rack/session/moneta'
require 'rack/builder'
require 'rack/lint'
require 'dragonfly/middleware'

module Locomotive
  module Steam
    module Middlewares

      class Stack

        def initialize(options)
          @options = prepare_options(options)
        end

        def create
          options = @options

          Rack::Builder.new do
            use Rack::Lint

            use Middlewares::Favicon

            if options[:serve_assets]
              use Middlewares::StaticAssets, {
                urls: ['/images', '/fonts', '/samples', '/media']
              }

              use Middlewares::DynamicAssets
            end

            use ::Dragonfly::Middleware, :steam

            use Rack::Session::Moneta, options[:moneta]

            use Middlewares::Logging

            use Middlewares::EntrySubmission

            use Middlewares::Path
            use Middlewares::Locale
            use Middlewares::Timezone

            use Middlewares::Page
            use Middlewares::TemplatizedPage

            run Middlewares::Renderer.new
          end
        end

        protected

        def prepare_options(options)
          {
            serve_assets: false,
            moneta: {
              store: Moneta.new(:Memory, :expires => true)
            }
          }.merge(options)
        end

      end

    end
  end
end
