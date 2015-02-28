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

    def class_name
      self[:class_name] || self[:target]
    end

    def required?; self[:required]; end
    def localized?; self[:localized]; end

    class SelectOption

      include Locomotive::Steam::Models::Entity

      attr_accessor :field

    end

  end
end
