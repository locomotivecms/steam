require 'locomotive/common'

require_relative 'steam/core_ext'
require_relative 'steam/exceptions'
require_relative 'steam/configuration'
require_relative 'steam/liquid'

require_relative 'steam/repositories'
require_relative 'steam/services'

# TODO: move into a file named dependencies
require 'sprockets'
require 'sprockets-sass'
require 'haml'
require 'compass'
require 'mimetype_fu'
require 'mime-types'
require 'rack/csrf'

require 'active_support'
require 'active_support/concern'
require 'active_support/deprecation'
require 'active_support/core_ext'

require 'mime/types'

module Locomotive
  module Steam

    # TEMPLATE_EXTENSIONS = %w(liquid haml)

    class << self
      attr_writer :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.reset
      @configuration = Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    # FIXME: not sure it will be ever needed
    # class << self
    #   def method_missing(name, *args, &block)
    #     Locomotive::Steam.configuration.public_send(name)
    #   rescue
    #     super
    #   end
    # end

  end
end
