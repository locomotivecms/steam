require 'moped'
require 'origin'

require_relative 'mongodb/origin'
require_relative 'mongodb/query'
require_relative 'mongodb/dataset'

module Locomotive::Steam

  class MongoDBAdapter < Struct.new(:database, :hosts)

    def all(mapper, selector = nil, options)
      dataset(mapper, selector, options)
    end

    def query(mapper, scope, &block)
      query = query_klass.new(scope, mapper.localized_attributes, &block)
      all(mapper, query.selector, query.options)
    end

    private

    def query_klass
      Locomotive::Steam::Adapters::MongoDB::Query
    end

    def dataset(mapper, selector = nil, options = {})
      Locomotive::Steam::Adapters::MongoDB::Dataset.new do
        collection(mapper).find(selector).sort(options[:sort]).map do |attributes|
          entity = mapper.to_entity(attributes)
        end
      end
    end

    def collection(mapper)
      session["locomotive_#{mapper.name}"]
    end

    def session
      Moped::Session.new([*hosts]).tap do |session|
        session.use database
      end
    end

  end

end


