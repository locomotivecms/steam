require 'moped'
require 'origin'

require_relative 'mongodb/origin'
require_relative 'mongodb/query'
require_relative 'mongodb/dataset'

module Locomotive::Steam

  class MongoDBAdapter < Struct.new(:database, :hosts)

    def all(mapper, query)
      dataset(mapper, query)
    end

    def query(mapper, scope, &block)
      query = query_klass.new(scope, mapper.localized_attributes, &block)
      all(mapper, query)
    end

    def key(name, operator)
      name.__send__(operator)
    end

    def identifier_name(mapper)
      :_id
    end

    def theme_assets_base_url(scope)
      ['', 'sites', scope.site._id.to_s, 'theme'].join('/')
    end

    private

    def query_klass
      Locomotive::Steam::Adapters::MongoDB::Query
    end

    def dataset(mapper, query)
      Locomotive::Steam::Adapters::MongoDB::Dataset.new do
        query.against(collection(mapper)).map do |attributes|
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


