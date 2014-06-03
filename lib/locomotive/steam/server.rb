require_relative 'core_ext'
require_relative 'monkey_patches'
require_relative 'liquid'
require_relative 'services'
require_relative 'middlewares'

require 'locomotive/models'

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

      set_path(env)

      fetch_site(env)

      set_services(env)

      @app.call(env)
    end

    protected

    def set_path(env)
      env['steam.path'] = options.fetch(:path)
    end
    def set_request(env)
      @request = Rack::Request.new(env)
      env['steam.request'] = @request
    end

    def fetch_site(env)
      # one single mounting point per site
      env['steam.site'] = Locomotive::Models[:sites].find_by_host(@request.host)
    end

    def set_services(env)
      env['steam.services'] = {
        dragonfly:      Locomotive::Steam::Services::Dragonfly.new(options.fetch(:path)),
        markdown:       Locomotive::Steam::Services::Markdown.new,
        external_api:   Locomotive::Steam::Services::ExternalAPI.new
      }
    end

  end
end
