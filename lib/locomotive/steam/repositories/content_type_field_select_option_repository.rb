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

      def by_name(name)
        scope.with_locale(query_locale) do
          query { where(name: name) }.first
        end
      end

      def by_id_or_name(id_or_name)
        find(id_or_name) || by_name(id_or_name)
      end

      def query_locale
        # if the select field is not localized, query in the default locale of the site
        content_type_field.localized? ? locale : scope.default_locale 
      end

    end
  end
end
