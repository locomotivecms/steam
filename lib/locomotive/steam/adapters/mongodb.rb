require 'moped'
require 'origin'

require_relative 'mongodb/origin'
require_relative 'mongodb/query'
require_relative 'mongodb/dataset'

module Locomotive::Steam

  class MongoDBAdapter < Struct.new(:options)

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

    def base_url(mapper, scope, entity = nil)
      return nil if scope.site.nil?

      # Note: mimic Carrierwave behaviour
      base = "/sites/#{scope.site._id.to_s}"

      case mapper.name
      when :theme_assets      then "#{base}/theme"
      when :pages             then "#{base}/pages/#{entity._id}/files"
      when :content_entries   then "#{base}/content_entry#{scope.context[:content_type]._id}/#{entity._id}/files"
      end
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

    def database
      options[:database]
    end

    def hosts
      options[:hosts]
    end

  end

end


