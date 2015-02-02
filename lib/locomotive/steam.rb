# require 'locomotive/models'
# require 'locomotive/decorators'
require 'locomotive/common'

require_relative 'steam/core_ext'
require_relative 'steam/exceptions'
require_relative 'steam/decorators'
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

#require 'httmultiparty'
require 'mime/types'

module Locomotive
  module Steam

    # Locomotive::Steam.repositories.get(:site)
    # Locomotive::Steam.repositories.get(:theme_assets, site)

    # a la fin de chaque requete => on clean les repositories

    # Locomotive::Steam.repositories[:theme_assets](site)

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

    class << self
      def method_missing(name, *args, &block)
        Locomotive::Steam.configuration.public_send(name)
      rescue
        super
      end
    end

  end
end
