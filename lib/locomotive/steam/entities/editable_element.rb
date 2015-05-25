module Locomotive::Steam

  class EditableElement

    include Locomotive::Steam::Models::Entity

    attr_accessor :page

    def initialize(attributes = {})
      super({
        content: nil,
        source: nil
      }.merge(attributes))
    end

    def source
      self[:source].blank? ? self.content : self[:source]
    end

    def default_content?
      self.content.blank?
    end

  end

end
