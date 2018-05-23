require 'locomotive/common'

require_relative      'steam/configuration'
require_relative_all  'steam/decorators'
require_relative      'steam/liquid'
require_relative      'steam/errors'

require_relative      'steam/models'
require_relative_all  'steam/entities'
require_relative      'steam/repositories'
require_relative      'steam/services'

module Locomotive
  module Steam

    FRONTMATTER_REGEXP      = /^(?<yaml>(---\s*\n.*?\n?)^(---\s*$\n?))?(?<template>.*)/mo.freeze
    JSON_FRONTMATTER_REGEXP = /^---\s*\n(?<json>(.*?\n?))?^(---\s*$\n?)(?<template>.*)/mo.freeze

    WILDCARD = 'content_type_template'.freeze

    CONTENT_ENTRY_ENGINE_CLASS_NAME   = /^Locomotive::ContentEntry(.*)$/o.freeze

    SECTIONS_SETTINGS_VARIABLE_REGEXP = /^\s*([a-z]+\.)?settings\.(?<id>.*)\s*$/o.freeze
    # SECTIONS_SETTINGS_TAG_REGEXP      = /(?<tag><[^\>]+>)\s*\z/mo.freeze
    SECTIONS_BLOCK_FORLOOP_REGEXP     = /(?<name>.+)-section\.blocks$/o.freeze

    IsHTTP    = /\Ahttps?:\/\//o.freeze

    IsLAYOUT  = /\Alayouts(\/|\z)/o.freeze

    class << self
      attr_writer   :configuration
      attr_accessor :extension_configurations
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

    def self.configure_extension(&block)
      (@extension_configurations ||= []) << block
    end

    # Shortcut to build the Rack stack
    def self.to_app
      (@extension_configurations || []).each do |block|
        block.call(@configuration)
      end

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
