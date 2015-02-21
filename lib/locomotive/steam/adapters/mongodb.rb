require 'moped'
require 'origin'

require_relative 'mongodb/origin'
require_relative 'mongodb/query'

module Locomotive::Steam

  class MongoDBAdapter < Struct.new(:database, :hosts)

    def all(mapper, selector = nil)
      dataset(mapper, selector)
    end

    def query(mapper, scope, &block)
      query = query_klass.new(scope, mapper.localized_attributes, &block)
      all(mapper, query.selector)
    end

    private

    def query_klass
      Locomotive::Steam::Adapters::MongoDB::Query
    end

    def dataset(mapper, selector = nil)
      collection(mapper).find(selector).map do |attributes|
        entity = mapper.to_entity(attributes)
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


