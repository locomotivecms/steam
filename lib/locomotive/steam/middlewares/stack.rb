# require 'rack/session/moneta'
# require 'rack/builder'
# require 'rack/lint'
# require 'dragonfly/middleware'

# module Locomotive
#   module Steam
#     module Middlewares

#       class Stack

#         def initialize(options)
#           @options = prepare_options(options)
#         end

#         def create
#           options = @options
#           # _self   = self

#           Rack::Builder.new do
#             use Rack::Lint

#             use Steam::Middlewares::Favicon

#             # if options[:serve_assets]
#             #   use Steam::Middlewares::StaticAssets, {
#             #     urls: ['/images', '/fonts', '/samples', '/media']
#             #   }
#             #   use Steam::Middlewares::DynamicAssets
#             # end

#             # use Rack::Csrf,
#             #   field:    'authenticity_token',
#             #   skip_if:  -> (request) {
#             #     !(request.post? && request.params[:content_type_slug].present?)
#             #   }

#             # use ::Dragonfly::Middleware, :steam

#             # use Rack::Session::Moneta, options[:moneta]

#             # _self.send(:use_steam_middlewares, builder)

#             use Middlewares::Logging
#             use Middlewares::Path

#             # foo = proc do |env|
#             #   puts "[EndPoint] finishing here..."
#             #   [ 200, {'Content-Type' => 'text/plain'}, ["b"] ]
#             # end

#             # run foo

#             run Steam::Middlewares::Renderer.new
#           end
#         end

#         protected

#         def use_steam_middlewares(builder)
#           # builder.use Middlewares::Logging
#           # builder.use Middlewares::Site
#           # builder.use Middlewares::Path

#           # builder.run Steam::Middlewares::Renderer.new

#           # builder.instance_eval do
#           #   use Middlewares::Logging

#           #   use Middlewares::Site

#           #   # use Middlewares::EntrySubmission

#           #   use Middlewares::Path

#           #   nil
#           #   # use Middlewares::Locale
#           #   # use Middlewares::Timezone

#           #   # use Middlewares::Page
#           #   # use Middlewares::TemplatizedPage
#           # end
#           # nil
#         end

#         # def prepare_options(options)
#         #   {
#         #     serve_assets: false,
#         #     moneta: {
#         #       store: Moneta.new(:Memory, expires: true)
#         #     }
#         #   }.merge(options)
#         # end

#       end

#     end
#   end
# end
