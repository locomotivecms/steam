module Locomotive
  module Steam

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
        entity_klass.new(attributes)
      end

      def entity_klass
        options[:entity]
      end

    end

  end
end
