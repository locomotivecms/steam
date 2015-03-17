module Locomotive::Steam

  class ContentType

    include Locomotive::Steam::Models::Entity
    extend Forwardable

    def_delegators :fields, :associations, :selects

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

    def fields_by_name
      @fields_by_name ||= (fields.all.inject({}) do |memo, field|
        memo[field.name] = field
        memo
      end).with_indifferent_access
    end

    def localized_names
      fields.localized_names + selects.map(&:name)
    end

    def label_field_name
      (self[:label_field_name] || fields.first.name).to_sym
    end

    def order_by
      name = self[:order_by] == 'manually' ? '_position' : self[:order_by]

      # check if name is an id of field
      if field = fields.find(name)
        name = field.name
      end

      { name.to_sym => self.order_direction.to_s }
    end

  end
end
