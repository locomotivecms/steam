$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../..'))

require_relative 'logger'
require_relative 'version'
require_relative 'exceptions'
require_relative 'server'

require 'locomotive/mounter'

module Locomotive
  module Steam
    class StandaloneServer < Server

      def initialize(path, options={})
        options.fetch(:logger) do
          Locomotive::Steam::Logger.setup(path, false)
        end

        reader = options.fetch(:reader) do
          _reader = Locomotive::Mounter::Reader::FileSystem.instance
          Proc.new { |_path| _reader.run!(path: _path) }
        end
        reader.call path

        Bundler.require 'monkey_patches'
        Bundler.require 'initializers'

        # run the rack app
        super(reader, disable_listen: true)
      end
    end
  end
end