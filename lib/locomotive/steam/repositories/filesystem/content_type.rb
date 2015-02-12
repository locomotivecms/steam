module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class ContentType < Struct.new(:loader, :site)

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

        end

      end
    end
  end
end
