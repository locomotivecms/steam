require 'rubygems'
require 'bundler/setup'

require_relative 'version'
require_relative 'exceptions'
require_relative 'server'

require 'locomotive/mounter'

module Locomotive
  module Steam
    class StandaloneServer < Server

      def initialize(path)
        Locomotive::Common::Logger.setup(path, false)

        # get the reader
        reader = Locomotive::Mounter::Reader::FileSystem.instance
        reader.run!(path: path)
        reader

        Bundler.require 'monkey_patches'
        Bundler.require 'initializers'

        # run the rack app
        super(reader, serve_assets: true)
      end
    end
  end
end