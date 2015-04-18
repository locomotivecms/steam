require 'sprockets'
require 'sprockets-sass'
require 'coffee_script'

Sprockets::Sass.add_sass_functions = false

module Locomotive::Steam

  class SprocketsEnvironment < ::Sprockets::Environment

    def initialize(root, options = {})
      super(root)

      @steam_path = root

      append_steam_paths

      install_yui_compressor(options)
    end

    private

    def append_steam_paths
      %w(fonts stylesheets javascripts).each do |name|
        append_path File.join(@steam_path, name)
      end
    end

    def install_yui_compressor(options)
      return unless options[:minify]

      require 'yui/compressor'

      if is_java_installed?
        # minify javascripts and stylesheets
        self.js_compressor  = YUI::JavaScriptCompressor.new
        self.css_compressor = YUI::CssCompressor.new
      else
        message = "[Important] YUICompressor requires java to be installed. The JAVA_HOME variable should also be set.\n"
        Locomotive::Common::Logger.warn message.red
        false
      end
    end

    def is_java_installed?
      `which java` != '' && (!ENV['JAVA_HOME'].blank? && File.exists?(ENV['JAVA_HOME']))
    end

  end

end
