require_relative 'concerns/key'
require_relative 'memory/order'
require_relative 'memory/condition'
require_relative 'memory/query'
require_relative 'memory/dataset'

module Locomotive::Steam

  class MemoryAdapter < Struct.new(:collection)

    include Locomotive::Steam::Adapters::Concerns::Key

    def all(mapper, scope)
      memoized_dataset(mapper, scope)
    end

    def query(mapper, scope, &block)
      _query(mapper, scope, &block)
    end

    def find(mapper, scope, id)
      _query(mapper, scope) { where(_id: id) }.first
    end

    private

    def _query(mapper, scope, &block)
      Locomotive::Steam::Adapters::Memory::Query.new(all(mapper, scope), scope.locale, &block)
    end

    def memoized_dataset(mapper, scope)
      return @dataset if @dataset
      dataset(mapper, scope)
    end

    def dataset(mapper, scope)
      Locomotive::Steam::Adapters::Memory::Dataset.new(mapper.name).tap do |dataset|
        collection.each do |attributes|
          # Note: very important to not manipulate the original attributes
          # since the attributes might be modified further by the to_entity method
          entity = mapper.to_entity(attributes.dup)
          dataset.insert(entity)
        end
      end
    end

  end

end


