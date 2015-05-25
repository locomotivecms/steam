module Locomotive::Steam

  class EditableElement

    include Locomotive::Steam::Models::Entity

    attr_accessor :page

    def initialize(attributes = {})
      super({
        source: nil
      }.merge(attributes))
    end

    def content
      self[:content] || self[:source]
    end

    def default_content?
      self.content.blank?
    end

  end

end
