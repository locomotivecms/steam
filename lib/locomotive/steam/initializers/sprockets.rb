require 'sprockets'
require 'sass'
require 'coffee_script'
require 'compass'
require 'autoprefixer-rails'
require 'open3'

require 'execjs'

module Locomotive::Steam

  class YUICompressorRuntimeError < RuntimeError
    attr_reader :errors
    #:nocov:
    def initialize(msg, errors)
      super(msg)
      @errors = errors
    end
  end

  module YUICompressorErrors

    #:nocov:
    def compress(stream_or_string)
      streamify(stream_or_string) do |stream|
        tempfile      = new_tempfile(stream)
        full_command  = "%s %s" % [command, tempfile.path]

        output, errors, exit_status = _compress(full_command, tempfile)

        if exit_status.exitstatus.zero?
          output
        else
          # Bourne shells tend to blow up here when the command fails, usually
          # because java is missing
          raise YUICompressorRuntimeError.new("Command '%s' returned non-zero exit status" %
            full_command, errors)
        end
      end
    end

    #:nocov:
    def _compress(command, tempfile)
      begin
        # FIXME: catch only useful information from the stderr output
        # output, errors, exit_status = '', [], nil
        output, errors, exit_status = Open3.capture3(command)
        errors = errors.split("\n").find_all { |l| l =~ /\s+[0-9]/ }
        [output, errors, exit_status]
      rescue Exception => e
        # windows shells tend to blow up here when the command fails
        raise RuntimeError, "compression failed: %s" % e.message
      ensure
        tempfile.close!
      end
    end

    #:nocov:
    def new_tempfile(stream)
      Tempfile.new('yui_compress').tap do |tempfile|
        tempfile.write stream.read
        tempfile.flush
      end
    end

  end

  class SprocketsEnvironment < ::Sprockets::Environment

    attr_reader :steam_path

    def initialize(root, options = {})
      super(root)

      @steam_path = root

      append_steam_paths

      install_yui_compressor(options)

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

    def install_yui_compressor(options)
      return unless options[:minify]

      if is_java_installed?
        require 'yui/compressor'

        [YUI::JavaScriptCompressor, YUI::CssCompressor].each do |klass|
          klass.send(:include, YUICompressorErrors)
        end

        # minify javascripts and stylesheets
        self.js_compressor  = YUI::JavaScriptCompressor.new
        self.css_compressor = YUI::CssCompressor.new
      else
        message = "[Important] YUICompressor requires java to be installed. The JAVA_HOME variable should also be set.\n"
        Locomotive::Common::Logger.warn message.red
        false
      end
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

    def is_java_installed?
      `which java` != '' && (!ENV['JAVA_HOME'].blank? && File.exists?(ENV['JAVA_HOME']))
    end

  end

end
