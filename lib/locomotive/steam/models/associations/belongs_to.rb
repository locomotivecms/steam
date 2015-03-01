require 'locomotive/steam/adapters/memory'
require 'morphine'

module Locomotive::Steam
  module Models

    # Note: represents an embedded collection
    class BelongsToAssociation

      attr_reader :repository

      def initialize(repository_klass, scope, adapter)
        # build a new instance of the target repository
        @repository = repository_klass.new(adapter)

        # Note: if we change the locale of the parent repository, that won't
        # reflect in that repository
        @repository.scope = scope.dup
      end

      def attach(name, entity)
        @name, @entity = name, entity
      end

      def target_id
        @entity[:"#{@name}_id"]
      end

      def method_missing(name, *args, &block)
        target = @repository.find(target_id)

        # replace the proxy class by the real target entity
        @entity[@name] = target

        target.try(:send, name, *args, &block)
      end

    end

  end
end
