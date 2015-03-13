module Locomotive::Steam
  module Models

    module Entity

      include Locomotive::Steam::Models::Concerns::Validation

      attr_accessor :attributes, :localized_attributes

      def initialize(attributes)
        @attributes = attributes.with_indifferent_access
      end

      def method_missing(name, *args, &block)
        if attributes.include?(name)
          self[name]
        else
          super
        end
      end

      def _id
        self[:_id]
      end

      def []=(name, value)
        attributes[name.to_sym] = value
      end

      def [](name)
        attributes[name.to_sym]
      end

    end
  end
end
