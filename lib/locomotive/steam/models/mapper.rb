module Locomotive::Steam
  module Models

    class Mapper

      attr_reader :name, :options, :localized_attributes

      def initialize(name, options, &block)
        @name, @options = name, options
        @localized_attributes = []

        instance_eval(&block) if block_given?
      end

      def set_localized_attributes(*args)
        @localized_attributes += [*args]
      end

      def to_entity(attributes)
        entity_klass.new(serialize(attributes))
      end

      def serialize(attributes)
        localized_attributes.each do |name|
          attributes[name] = I18nField.new(name, attributes[name])
        end
        attributes
      end

      def entity_klass
        options[:entity]
      end

    end

  end
end
