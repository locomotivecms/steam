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

    alias :target :class_name

    def target_id
      return @target_id if @target_id

      @target_id = if self.target =~ /^Locomotive::ContentEntry(.*)$/o
        $1
      else
        self.target
      end
    end

    def required?; self[:required]; end
    def localized?; self[:localized]; end

    def association_options
      @attributes.slice(:inverse_of, :order_by).merge(class_name: class_name)
    end

    class SelectOption

      include Locomotive::Steam::Models::Entity

      attr_accessor :field

    end

  end
end
