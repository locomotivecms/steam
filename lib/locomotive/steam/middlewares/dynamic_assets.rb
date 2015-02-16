require 'coffee_script'
require 'yui/compressor'

module Locomotive::Steam
  module Middlewares

    class DynamicAssets

      attr_reader :app, :regexp

      def initialize(app, options)
        @app    = app
        @regexp = /^\/(javascripts|stylesheets)\/(.*)$/o

        @assets = ::Sprockets::Environment.new(options[:root]).tap do |env|
          install_yui_compressor(env, options)

          %w(fonts stylesheets javascripts).each do |name|
            env.append_path File.join(options[:root], name)
          end
        end
      end

      def call(env)
        if env['PATH_INFO'] =~ self.regexp
          env['PATH_INFO'] = $2
          @assets.call(env)
        else
          app.call(env)
        end
      end

      private

      def install_yui_compressor(sprockets, options)
        return unless options[:minify]

        if is_java_installed?
          # minify javascripts and stylesheets
          sprockets.js_compressor  = YUI::JavaScriptCompressor.new
          sprockets.css_compressor = YUI::CssCompressor.new
        else
          message = "[Important] YUICompressor requires java to be installed. The JAVA_HOME variable should also be set.\n"
          Locomotive::Common::Logger.warn message.red
        end
      end

      def is_java_installed?
        `which java` != '' && (!ENV['JAVA_HOME'].blank? && File.exists?(ENV['JAVA_HOME']))
      end

    end

  end
end
