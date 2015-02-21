module Locomotive::Steam
  module Models

    module Repository

      extend ActiveSupport::Concern

      class RecordNotFound < StandardError; end

      attr_accessor :adapter, :current_site, :current_locale

      def initialize(adapter, current_site = nil, current_locale = nil)
        @adapter        = adapter
        @current_site   = current_site
        @current_locale = current_locale
      end

      def find(id)
        adapter.find(mapper, scope, id)
      end

      def query(&block)
        adapter.query(mapper, scope, &block)
      end

      alias :all :query

      # def create(entity)
      #   entity.id = adapter.create(collection_name, entity)
      # end

      # def persisted?(entity)
      #   !!entity.id && adapter.persisted?(collection_name, entity)
      # end

      # def update(entity)
      #   adapter.update(collection_name, entity)
      # end

      # def destroy(entity)
      #   adapter.destroy(collection_name, entity)
      # end

      def mapper
        name, options, block = mapper_options
        @mapper ||= Mapper.new(name, options, &block)
      end

      def scope
        @scope ||= Scope.new(current_site, current_locale)
      end

      # def collection_name
      #   mapper.name
      # end

      module ClassMethods

        def mapping(name, options = {}, &block)
          class_eval do
            define_method(:mapper_options) { [name, options, block] }
          end
        end

      end

    end

  end
end
