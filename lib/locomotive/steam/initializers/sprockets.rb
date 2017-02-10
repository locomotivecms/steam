require 'sprockets'
require 'sass'
require 'coffee_script'
require 'compass'
require 'uglifier'
require 'autoprefixer-rails'

require 'execjs'

module Locomotive::Steam

  class SprocketsEnvironment < ::Sprockets::Environment

    attr_reader :steam_path

    def initialize(root, options = {})
      super(root)

      @steam_path = root

      append_steam_paths

      install_minifiers if options[:minify]

      install_autoprefixer

      context_class.class_eval do
        def asset_path(path, options = {})
          path
        end
      end
    end

    private

    def append_steam_paths
      %w(fonts stylesheets javascripts).each do |name|
        append_path File.join(@steam_path, name)
      end

      Compass::Frameworks::ALL.each { |f| append_path(f.stylesheets_directory) }
    end

    def install_minifiers
      # minify javascripts and stylesheets
      self.js_compressor  = :uglify
      self.css_compressor = :scss
    end

    def install_autoprefixer
      file = File.join(root, '..', 'config', 'autoprefixer.yml')

      if File.exists?(file)
        params = (::YAML.load_file(file) || {}).symbolize_keys
        AutoprefixerRails.install(self, params)

        Locomotive::Common::Logger.info "[Autoprefixer] detected and installed".light_white

        if ENV['EXECJS_RUNTIME'].blank?
          Locomotive::Common::Logger.warn "[Autoprefixer]".light_white + " [Warning] if you notice bad performance, install NodeJS and run \"export EXECJS_RUNTIME=Node\" in your shell"
        end

        Locomotive::Common::Logger.info "\n"
      end
    end

  end

end
