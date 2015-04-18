require 'locomotive/common'

require_relative      'steam/configuration'
require_relative_all  'steam/decorators'
require_relative      'steam/liquid'

require_relative      'steam/models'
require_relative_all  'steam/entities'
require_relative      'steam/repositories'
require_relative      'steam/services'

module Locomotive
  module Steam

    FRONTMATTER_REGEXP = /^(?<yaml>(---\s*\n.*?\n?)^(---\s*$\n?))?(?<template>.*)/mo

    WILDCARD = 'content_type_template'.freeze

    CONTENT_ENTRY_ENGINE_CLASS_NAME = /^Locomotive::ContentEntry(.*)$/o

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

      require_relative 'steam/initializers'
    end

    # Shortcut to build the Rack stack
    def self.to_app
      require_relative 'steam/server'
      Server.to_app
    end

    # FIXME: not sure it will ever be needed
    # class << self
    #   def method_missing(name, *args, &block)
    #     Locomotive::Steam.configuration.public_send(name)
    #   rescue
    #     super
    #   end
    # end

  end
end
