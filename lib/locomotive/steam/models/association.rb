require 'locomotive/steam/adapters/memory'
require 'morphine'

module Locomotive::Steam
  module Models

    # Note: represents an embedded collection
    class Association < SimpleDelegator

      include Morphine

      register :adapter do
        Locomotive::Steam::MemoryAdapter.new(nil)
      end

      def initialize(repository_klass, collection)
        adapter.collection = collection
        @repository = repository_klass.new(adapter)
        super(@repository)
      end

      def attach(name, entity)
        @repository.send(:"#{name}=", entity)
      end

    end

  end
end
