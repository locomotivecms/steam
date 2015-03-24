module Locomotive::Steam

  class ContentTypeField

    include Locomotive::Steam::Models::Entity

    attr_accessor :content_type

    def initialize(attributes = {})
      super({
        type:       :string,
        localized:  false,
        required:   false,
        unique:     false
      }.merge(attributes))
    end

    def type
      self[:type].try(:to_sym)
    end

    def class_name
      self[:class_name] || self[:target]
    end

    def order_by
      if (order_by = self[:order_by]).present?
        name, direction = order_by.split
        { name.to_sym => direction || 'asc' }
      else
        type == :has_many ? { :"position_in_#{self[:inverse_of]}" => 'asc' } : nil
      end
    end

    alias :target :class_name

    def target_id
      return @target_id if @target_id

      @target_id = if self.target =~ Locomotive::Steam::CONTENT_ENTRY_ENGINE_CLASS_NAME
        $1
      else
        self.target
      end
    end

    def required?; self[:required]; end
    def localized?; self[:localized]; end

    def association_options
      {
        target_id:  target_id,
        inverse_of: self[:inverse_of],
        order_by:   order_by
      }
    end

    class SelectOption

      include Locomotive::Steam::Models::Entity

      attr_accessor :field

      def name
        self[:name]
      end

    end

  end
end
