module Locomotive::Steam

  class ContentType

    include Locomotive::Steam::Models::Entity

    def initialize(attributes = {})
      super({
        order_by:         '_position',
        order_direction:  'asc'
      }.merge(attributes))
    end

    def fields
      # Note: this returns an instance of the ContentTypeFieldRepository class
      self.entries_custom_fields
    end

    def label_field_name
      (self[:label_field_name] || fields.first.name).to_sym
    end

    def order_by
      name = self[:order_by] == 'manually' ? '_position' : self[:order_by]
      [name, self.order_direction]
    end

  end
end
