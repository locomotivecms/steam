module Locomotive::Steam
  module Models

    class Mapper

      attr_reader :name, :options, :default_attributes, :localized_attributes, :associations

      def initialize(name, options, repository, &block)
        @name, @options, @repository = name, options, repository

        @localized_attributes = []
        @default_attributes   = []
        @associations         = []

        instance_eval(&block) if block_given?
      end

      def localized_attributes(*args)
        @localized_attributes += [*args]
      end

      def default_attribute(name, value)
        @default_attributes += [[name.to_sym, value]]
      end

      # Note: only works for embedded-type associations
      def association(name, repository_klass)
        @associations += [[name.to_sym, repository_klass]]
      end

      def to_entity(attributes)
        entity_klass.new(serialize(attributes)).tap do |entity|
          attach_entity_to_associations(entity)
          set_default_attributes(entity)
        end
      end

      def serialize(attributes)
        serialize_localized_attributes(attributes)

        serialize_associations(attributes)

        attributes
      end

      def entity_klass
        options[:entity]
      end

      private

      # create a proxy class for each localized attribute
      def serialize_localized_attributes(attributes)
        @localized_attributes.each do |name|
          attributes[name] = I18nField.new(name, attributes[name])
        end
      end

      # build the embedded associations
      def serialize_associations(attributes)
        @associations.each do |name, repository_klass|
          attributes[name] = Association.new(repository_klass, attributes[name])
        end
      end

      def attach_entity_to_associations(entity)
        @associations.each do |(name, _)|
          key = name.to_s.singularize.to_sym
          entity[name].attach(key, entity)
        end
      end

      def set_default_attributes(entity)
        @default_attributes.each do |(name, value)|
          # _value = value.respond_to?(:call) ? @repository.instance_eval(&value) : value
          _value = value.respond_to?(:call) ? value.call(@repository) : value
          entity.send(:"#{name}=", _value)
        end
      end

    end

  end
end
