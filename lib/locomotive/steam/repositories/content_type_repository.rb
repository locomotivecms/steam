module Locomotive
  module Steam

    class ContentTypeRepository

      include Models::Repository

      # Entity mapping
      mapping :content_types, entity: ContentType do
        embedded_association :entries_custom_fields, ContentTypeFieldRepository
      end

      def by_slug(slug_or_content_type)
        if slug_or_content_type.is_a?(String)
          query { where(slug: slug_or_content_type) }.first
        else
          slug_or_content_type
        end
      end

      def look_for_unique_fields(content_type)
        return nil if content_type.nil?
        content_type.fields.unique
      end

      def fields_for(content_type)
        return nil if content_type.nil?
        content_type.fields
      end

      def select_options(content_type, name)
        return nil if content_type.nil? || name.nil?
        content_type.fields.select_options(name.to_s)
      end

    end
  end
end
