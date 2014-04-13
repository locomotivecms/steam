module Locomotive::Steam
  module Middlewares

    class Base

      attr_accessor :app, :request, :path
      attr_accessor :liquid_assigns, :services
      attr_accessor :mounting_point, :page, :content_entry

      def initialize(app = nil)
        @app = app
      end

      def call(env)
        dup._call(env) # thread-safe purpose
      end

      def _call(env)
        self.set_accessors(env)
      end

      protected

      def set_accessors(env)
        %w(path request mounting_point page content_entry services).each do |name|
          self.send(:"#{name}=", env["steam.#{name}"])
        end

        env['steam.liquid_assigns'] ||= {}
        self.liquid_assigns = env['steam.liquid_assigns']
      end

      def site
        self.mounting_point.site
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
        Locomotive::Steam::Logger.info msg
      end

    end

  end
end