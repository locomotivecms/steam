# require 'rack/static'

# module Locomotive::Steam
#   module Middlewares

#     class StaticAssets < ::Rack::Static

#       alias_method :call_without_threadsafety, :call

#       def call(env)
#         dup._call(env) # thread-safe purpose
#       end

#       def _call(env)
#         # mounting_point = env['steam.mounting_point']

#         @file_server = Rack::File.new(mounting_point.assets_path)

#         call_without_threadsafety(env)
#       end

#     end

#   end
# end
