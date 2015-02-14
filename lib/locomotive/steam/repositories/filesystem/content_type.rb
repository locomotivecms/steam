module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class ContentType < Struct.new(:loader, :site, :current_locale)

          include Concerns::Queryable

          set_collection model: Filesystem::Models::ContentType, sanitizer: Filesystem::Sanitizers::ContentType

          # Engine: site.where(slug: slug_or_content_type).first
          def by_slug(slug_or_content_type)
            if slug_or_content_type.is_a?(String)
              query { where(slug: slug_or_content_type) }.first
            else
              slug_or_content_type
            end
          end

          # Engine: content_type.entries.klass.send(:"#{name}_options").map { |option| option['name'] }
          def select_options(type, name)
            return nil if type.nil? || name.nil?

            field = type.fields_by_name[name]

            if field.type == :select
              localized_attribute(field, :select_options)
            else
              nil
            end
          end

        end

      end
    end
  end
end
