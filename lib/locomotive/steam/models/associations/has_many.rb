require 'locomotive/steam/adapters/memory'
require 'morphine'

module Locomotive::Steam
  module Models

    # Note: represents an embedded collection
    class HasManyAssociation

      attr_reader :repository

      def initialize(repository_klass, scope, adapter, options = {}, &block)
        # build a new instance of the target repository
        @repository = repository_klass.new(adapter)

        # Note: if we change the locale of the parent repository, that won't
        # reflect in that repository
        @repository.scope = scope.dup

        # the block will executed when a method of the target will be called
        @block = block_given? ? block : nil

        @options = options
      end

      def attach(name, entity)
        @name, @entity = name, entity
      end

      def target_key
        :"#{@options[:inverse_of]}_id"
      end

      def entity_id
        @repository.i18n_value_of(@entity, @repository.identifier_name)
      end

      def method_missing(name, *args, &block)
        @block.call(@repository) if @block

        @repository.local_conditions[target_key] = entity_id

        @repository.send(name, *args, &block)
      end

    end

  end
end
