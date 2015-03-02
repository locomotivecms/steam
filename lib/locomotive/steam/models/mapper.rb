module Locomotive::Steam
  module Models

    class Mapper

      attr_reader :name, :options, :default_attributes, :localized_attributes, :associations

      def initialize(name, options, repository, &block)
        @name, @options, @repository = name, options, repository

        @localized_attributes = []
        @default_attributes   = []
        @associations         = { embedded: [], belongs_to: [] }

        instance_eval(&block) if block_given?
      end

      def localized_attributes(*args)
        @localized_attributes += [*args]
      end

      def default_attribute(name, value)
        @default_attributes += [[name.to_sym, value]]
      end

      def belongs_to_association(name, repository_klass, &block)
        @associations[:belongs_to] += [[name.to_sym, repository_klass, block]]
      end

      def embedded_association(name, repository_klass)
        @associations[:embedded] += [[name.to_sym, repository_klass]]
      end

      def to_entity(attributes)
        entity_klass.new(serialize(attributes)).tap do |entity|
          attach_entity_to_embedded_associations(entity)
          attach_entity_to_belongs_to_associations(entity)
          set_default_attributes(entity)
        end
      end

      def serialize(attributes)
        serialize_localized_attributes(attributes)

        serialize_embedded_associations(attributes)
        serialize_belongs_to_associations(attributes)

        attributes
      end

      def entity_klass
        options[:entity]
      end

      def i18n_value_of(entity, name, locale)
        value = entity.send(name.to_sym)
        value.respond_to?(:translations) ? value[locale] : value
      end

      private

      # create a proxy class for each localized attribute
      def serialize_localized_attributes(attributes)
        @localized_attributes.each do |name|
          attributes[name] = I18nField.new(name, attributes[name])
        end
      end

      # build the embedded associations
      def serialize_embedded_associations(attributes)
        @associations[:embedded].each do |(name, repository_klass)|
          attributes[name] = EmbeddedAssociation.new(repository_klass, attributes[name], @repository.scope)
        end
      end

      # build the belongs_to associations
      def serialize_belongs_to_associations(attributes)
        @associations[:belongs_to].each do |(name, repository_klass, block)|
          attributes[name] = BelongsToAssociation.new(repository_klass, @repository.scope, @repository.adapter, &block)
        end
      end

      def attach_entity_to_embedded_associations(entity)
        @associations[:embedded].each do |(name, _)|
          key = self.name.to_s.singularize.to_sym
          entity[name].attach(key, entity) # Note: entity[name] is a proxy class
        end
      end

      def attach_entity_to_belongs_to_associations(entity)
        @associations[:belongs_to].each do |(name, _)|
          entity[name].attach(name, entity)
        end
      end

      def set_default_attributes(entity)
        @default_attributes.each do |(name, value)|
          _value = value.respond_to?(:call) ? value.call(@repository) : value
          entity.send(:"#{name}=", _value)
        end
      end

    end

  end
end
