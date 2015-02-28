module Locomotive
  module Steam

    class ContentTypeFieldSelectOptionRepository

      include Models::Repository

      attr_accessor :content_type_field

      # Entity mapping
      mapping :content_type_field_select_options, entity: ContentTypeField::SelectOption do
        default_attribute :field, -> (repository) { repository.content_type_field }

        localized_attributes :name
      end

      def all
        query { order_by(position: :asc) }.all
      end

    end
  end
end
