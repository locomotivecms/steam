require 'locomotive/steam/adapters/memory'
require 'morphine'

module Locomotive::Steam
  module Models

    class BelongsToAssociation

      attr_reader :repository

      def initialize(repository_klass, scope, adapter, &block)
        # build a new instance of the target repository
        @repository = repository_klass.new(adapter)

        # Note: if we change the locale of the parent repository, that won't
        # reflect in that repository
        @repository.scope = scope.dup

        # the block will executed when a method of the target will be called
        @block = block_given? ? block : nil
      end

      def attach(name, entity)
        @name, @entity = name, entity
      end

      def target_id
        @entity[:"#{@name}_id"]
      end

      def method_missing(name, *args, &block)
        @block.call(@repository) if @block

        target = @repository.find(target_id)

        # replace the proxy class by the real target entity
        @entity[@name] = target

        target.try(:send, name, *args, &block)
      end

    end

  end
end
