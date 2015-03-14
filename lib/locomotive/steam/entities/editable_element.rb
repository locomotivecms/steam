module Locomotive::Steam

  class EditableElement

    include Locomotive::Steam::Models::Entity

    attr_accessor :page

    def default_content?
      !!self[:default_content]
    end

  end

end
