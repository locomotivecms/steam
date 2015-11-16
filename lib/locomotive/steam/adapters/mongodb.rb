require 'mongo'
require 'origin'

require_relative 'mongodb/origin'
require_relative 'mongodb/query'
require_relative 'mongodb/dataset'
require_relative 'mongodb/command'

module Locomotive::Steam

  class MongoDBAdapter

    attr_accessor_initialize :options

    def all(mapper, query)
      dataset(mapper, query)
    end

    def query(mapper, scope, &block)
      query = query_klass.new(scope, mapper.localized_attributes, &block)
      all(mapper, query)
    end

    def count(mapper, scope, &block)
      query = query_klass.new(scope, mapper.localized_attributes, &block)
      query.against(collection(mapper)).count
    end

    def find(mapper, scope, id)
      query(mapper, scope) { where(_id: BSON::ObjectId.from_string(id)) }.first
    end

    def create(mapper, scope, entity)
      command(mapper).insert(entity)
    end

    def delete(mapper, scope, entity)
      command(mapper).delete(entity)
    end

    def key(name, operator)
      name.to_sym.__send__(operator.to_sym)
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

    def command_klass
      Locomotive::Steam::Adapters::MongoDB::Command
    end

    def dataset(mapper, query)
      Locomotive::Steam::Adapters::MongoDB::Dataset.new do
        query.against(collection(mapper)).map do |attributes|
          entity = mapper.to_entity(attributes)
        end
      end
    end

    def command(mapper)
      command_klass.new(collection(mapper), mapper)
    end

    def collection(mapper)
      session["locomotive_#{mapper.name}"]
    end

    def session
      Thread.current[:mongo_session] ||= if uri
        Mongo::Client.new(uri)
      else
        client = Mongo::Client.new([*hosts], database: database)
        client = client.with(user: username, password: password) if username && password
        client
      end
    end

    def uri
      options[:uri]
    end

    def database
      options[:database]
    end

    def hosts
      options[:hosts]
    end

    def username
      options[:username]
    end

    def password
      options[:password]
    end

  end

end


