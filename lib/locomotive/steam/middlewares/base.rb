module Locomotive::Steam
  module Middlewares

    class Base

      attr_accessor :app, :request, :path
      attr_accessor :liquid_assigns, :services
      attr_accessor :site, :page, :content_entry, :locale

      def initialize(app = nil)
        @app = app
      end

      def call(env)
        if Locomotive::Steam.mode == :test
          _call(env)
        else
          dup._call(env) # thread-safe purpose
        end
      end

      def _call(env)
        code, headers, response = @app.call(env)
        self.set_accessors(env)
        [code, headers, [response]]
      end

      protected

      def set_accessors(env)
        %w(path site request page content_entry services locale).each do |name|
          self.send(:"#{name}=", env.fetch("steam.#{name}", nil))
        end

        env['steam.liquid_assigns'] ||= {}
        self.liquid_assigns = env.fetch('steam.liquid_assigns')
      end

      def params
        self.request.params.deep_symbolize_keys
      end

      def html?
        ['text/html', 'application/x-www-form-urlencoded'].include?(self.request.media_type) &&
        !self.request.xhr? &&
        !self.json?
      end

      def json?
        self.request.content_type == 'application/json' || File.extname(self.request.path) == '.json'
      end

      def redirect_to(location, type = 301)
        self.log "Redirected to #{location}"
        [type, { 'Content-Type' => 'text/html', 'Location' => location }, []]
      end

      def log(msg)
        Locomotive::Common::Logger.info msg
      end

    end

  end
end
