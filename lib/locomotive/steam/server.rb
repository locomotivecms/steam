require_relative 'core_ext'
require_relative 'monkey_patches'

require_relative 'morphine'
require_relative 'repositories'
require_relative 'services'

require_relative 'liquid'
require_relative 'middlewares'

module Locomotive::Steam
  class Server

    attr_reader :app, :options

    def initialize(options = {})
      @options    = options

      stack       = Middlewares::Stack.new(options)
      @app        = stack.create
    end

    def call(env)
      dup._call(env) # thread-safe purpose
    end

    def _call(env)
      set_request(env)

      register_services(env)

      fetch_site(env)

      @app.call(env)
    end

    protected

    def set_request(env)
      env['steam.request'] = Rack::Request.new(env)
    end

    def fetch_site(env)
      site = env['steam.services'].site_finder.find
      env['steam.site'] = env['steam.services'].repositories.current_site = site
    end

    def register_services(env)
      env['steam.services'] = Locomotive::Steam::Services.instance(env['steam.request'], options)
    end

  end
end
