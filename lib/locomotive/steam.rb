require 'locomotive/models'
require 'locomotive/decorators'
require 'locomotive/common'

require_relative 'steam/exceptions'
require_relative 'steam/decorators'
require_relative 'steam/configuration'

require 'sprockets'
require 'sprockets-sass'
require 'haml'
require 'compass'

#require 'httmultiparty'
require 'mime/types'

module Locomotive
  module Steam
    TEMPLATE_EXTENSIONS = %w(liquid haml)

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

    class << self
      def method_missing(name, *args, &block)
        Locomotive::Steam.configuration.public_send(name)
      rescue
        super
      end
    end

  end
end
