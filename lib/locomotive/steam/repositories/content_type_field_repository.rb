module Locomotive
  module Steam

    class ContentTypeFieldRepository

      include Models::Repository

      attr_accessor :content_type

      # Entity mapping
      mapping :content_type_fields, entity: ContentTypeField do
        default_attribute :content_type, -> (repository) { repository.content_type }

        embedded_association :select_options, ContentTypeFieldSelectOptionRepository
      end

      def associations
        query { where(k(:type, :in) => %i(belongs_to has_many many_to_many)) }.all
      end

      def unique
        query { where(unique: true) }.all.inject({}) do |memo, field|
          memo[field.name] = field
          memo
        end
      end

      def required
        query { where(required: true) }.all
      end

      def localized_names
        query { where(localized: true) }.all.map(&:name)
      end

      def select_options(name)
        if field = first { where(name: name, type: :select) }
          field.select_options.all
        else
          nil
        end
      end

    end
  end
end
