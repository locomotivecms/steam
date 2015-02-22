require_relative 'memory/order'
require_relative 'memory/condition'
require_relative 'memory/query'
require_relative 'memory/dataset'

module Locomotive::Steam

  class MemoryAdapter < Struct.new(:collection)

    def all(mapper, scope)
      memoized_dataset(mapper, scope)
    end

    def query(mapper, scope, &block)
      _query(mapper, scope, &block)
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
          entity = mapper.to_entity(attributes)
          dataset.insert(entity)
        end
      end
    end

  end

end


