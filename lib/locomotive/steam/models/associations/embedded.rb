require 'locomotive/steam/adapters/memory'
require 'morphine'

module Locomotive::Steam
  module Models

    # Note: represents an embedded collection
    class EmbeddedAssociation

      include Morphine

      register :adapter do
        Locomotive::Steam::MemoryAdapter.new(nil)
      end

      # use the scope from the parent repository
      # one of the benefits is that if we change the current locale
      # of the parent repository, that will change the local repository
      # as well.
      def initialize(repository_klass, collection, scope, options = {})
        adapter.collection = collection || []

        @repository = repository_klass.new(adapter)
        @repository.scope = scope

        @options = options
      end

      # In order to keep track of the entity which owns
      # the association.
      def __attach__(entity)
        name = @options[:mapper_name].to_s.singularize.to_sym
        @repository.send(:"#{name}=", entity)
      end

      def method_missing(name, *args, &block)
        @repository.send(name, *args, &block)
      end

    end

  end
end
