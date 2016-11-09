# module Locomotive::Steam
#   module Middlewares

#     class Warden

#       def initialize(app)
#         @warden = ::Warden::Manager.new(app) do |manager|
#           manager.default_strategies :steam_password
#           manager.failure_app = app
#         end
#       end

#       def call(env)
#         @warden.call(env)
#       end

#     end

#   end
# end
