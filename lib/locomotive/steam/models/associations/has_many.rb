require 'locomotive/steam/adapters/memory'
require 'morphine'

module Locomotive::Steam
  module Models

    # Note: represents an embedded collection
    class HasManyAssociation

      attr_reader :repository

      def initialize(repository_klass, scope, adapter)
        @repository = repository_klass.new(adapter)

        # Note: if we change the locale of the parent repository, that won't
        # reflect in that repository
        @repository.scope = scope.dup
      end

      def set_condition
        @repository.association_condition = { }
      end

      def method_missing(name, *args, &block)
        @repository.send(name, *args, &block)
      end

      # include Morphine

      # # use the scope from the parent repository
      # # one of the benefits is that if we change the current_locale
      # # of the parent repository, that will change the local repository
      # # as well.
      # def initialize(repository_klass, collection, scope)
      #   adapter.collection = collection

      #   @repository = repository_klass.new(adapter)
      #   @repository.scope = scope
      # end

      # # In order to keep track of the entity which owns
      # # the association.
      # def attach(name, entity)
      #   @repository.send(:"#{name}=", entity)
      # end



    end

  end
end
