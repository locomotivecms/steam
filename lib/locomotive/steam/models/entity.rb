module Locomotive::Steam
  module Models

    module Entity

      include Locomotive::Steam::Models::Concerns::Validation

      attr_accessor :attributes, :associations, :localized_attributes, :base_url

      def initialize(attributes)
        @attributes = attributes.with_indifferent_access
      end

      def method_missing(name, *args, &block)
        _name = name.to_s
        if attributes.include?(_name)
          self[_name]
        elsif _name.end_with?('=') && attributes.include?(_name.chop)
          self[_name.chop] = args.first
        else
          super
        end
      end

      def respond_to?(name, include_private = false)
        attributes.include?(name.to_s) || super
      end

      def _id
        self['_id']
      end

      def []=(name, value)
        attributes[name] = value
      end

      def [](name)
        attributes[name]
      end

      def serialize
        attributes.dup
      end

    end
  end
end
