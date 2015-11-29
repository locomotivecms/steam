module Locomotive::Steam

  class EditableElement

    include Locomotive::Steam::Models::Entity

    attr_accessor :page

    def initialize(attributes = {})
      super({
        block:          nil,
        content:        nil,
        source:         nil,
        inline_editing: true
      }.merge(attributes))
    end

    def source
      self[:source].blank? ? self.content : self[:source]
    end

    def format
      self[:format] || 'html' # only editable_text elements
    end

  end

end
