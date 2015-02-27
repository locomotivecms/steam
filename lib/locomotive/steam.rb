require 'locomotive/common'

require 'active_support'
require 'active_support/concern'
require 'active_support/deprecation'
require 'active_support/core_ext'

require_relative      'steam/core_ext'
require_relative      'steam/configuration'
require_relative_all  'steam/monkey_patches'
require_relative_all  'steam/decorators'
require_relative      'steam/liquid'

require_relative      'steam/models'
require_relative_all  'steam/entities'

# TODO
require_relative      'steam/repositories/site_repository'
require_relative      'steam/repositories/page_repository'
require_relative      'steam/repositories/editable_element_repository'
require_relative      'steam/repositories/snippet_repository'

require_relative      'steam/services'

module Locomotive
  module Steam

    FRONTMATTER_REGEXP = /^(?<yaml>(---\s*\n.*?\n?)^(---\s*$\n?))?(?<template>.*)/mo

    WILDCARD = 'content_type_template'.freeze

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
