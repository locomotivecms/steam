module Locomotive::Steam
  module Models

    module Repository

      extend ActiveSupport::Concern
      extend Forwardable

      class RecordNotFound < StandardError; end

      attr_accessor :adapter, :scope

      def_delegators :@scope, :site, :site=, :locale, :locale=

      def initialize(adapter, site = nil, locale = nil)
        @adapter  = adapter
        @scope    = Scope.new(site, locale)
      end

      def build(attributes, &block)
        mapper.to_entity(attributes)
      end

      def create(entity)
        adapter.create(entity)
      end

      def find(id)
        adapter.find(mapper, scope, id)
      end

      def query(&block)
        adapter.query(mapper, scope, &block)
      end

      def first(&block)
        adapter.query(mapper, scope, &block).first
      end

      def k(name, operator)
        adapter.key(name, operator)
      end

      def identifier_name
        if adapter.respond_to?(:identifier_name)
          adapter.identifier_name(mapper)
        else
          :_id
        end
      end

      alias :all :query

      def mapper(memoized = true)
        name, options, block = mapper_options

        return @mapper if @mapper && memoized

        @mapper = Mapper.new(name, options, self, &block)
      end

      def i18n_value_of(entity, name)
        mapper.i18n_value_of(entity, name, locale)
      end

      # TODO: not sure about that. could it be used further in the dev
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
