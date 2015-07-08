module Locomotive::Steam
  module Models

    module Entity

      include Locomotive::Steam::Models::Concerns::Validation

      attr_accessor :attributes, :associations, :localized_attributes, :base_url

      def initialize(attributes)
        @attributes = attributes.with_indifferent_access
      end

      def method_missing(name, *args, &block)
        if attributes.include?(name)
          self[name]
        elsif name.to_s.end_with?('=') && attributes.include?(name.to_s.chop)
          self[name.to_s.chop] = args.first
        else
          super
        end
      end

      def respond_to?(name, include_private = false)
        attributes.include?(name) || super
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

      def serialize
        attributes.dup
      end

    end
  end
end
