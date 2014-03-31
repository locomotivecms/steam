$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../..'))

require 'locomotive/steam/logger'
require 'locomotive/steam/version'
require 'locomotive/steam/exceptions'
require 'locomotive/steam/server'
require 'locomotive/mounter'

module Locomotive
  module Steam
    class StandaloneServer < Server

      def initialize(path)
        Locomotive::Steam::Logger.setup(path, false)

        # get the reader
        reader = Locomotive::Mounter::Reader::FileSystem.instance
        reader.run!(path: path)
        reader

        Bundler.require 'misc'

        # run the rack app
        super(reader, disable_listen: true)
      end
    end
  end
end