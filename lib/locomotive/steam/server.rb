require_relative 'core_ext'
require_relative 'monkey_patches'
require_relative 'liquid'
require_relative 'services'
require_relative 'middlewares'

module Locomotive::Steam
  class Server

    attr_reader :reader, :app, :options

    def initialize(reader, options = {})
      @reader   = reader
      @options  = options

      stack     = Middlewares::Stack.new(options)
      @app      = stack.create
    end

    def call(env)
      dup._call(env) # thread-safe purpose
    end

    def _call(env)
      set_request(env)

      set_mounting_point(env)

      set_services(env)

      @app.call(env)
    end

    protected

    def set_request(env)
      @request = Rack::Request.new(env)
      env['steam.request'] = @request
    end

    def set_mounting_point(env)
      # one single mounting point per site
      @mounting_point = @reader.new_mounting_point(@request.host)
      env['steam.mounting_point'] = @reader.mounting_point
    end

    def set_services(env)
      env['steam.services'] = {
        dragonfly:      Locomotive::Steam::Services::Dragonfly.new(@mounting_point.path),
        markdown:       Locomotive::Steam::Services::Markdown.new,
        external_api:   Locomotive::Steam::Services::ExternalAPI.new
      }
    end

  end
end
