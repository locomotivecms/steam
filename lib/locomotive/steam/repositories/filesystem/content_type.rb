module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class ContentType < Struct.new(:site)

          def by_slug(slug_or_content_type)
            # if slug_or_content_type.is_a?(String)
            #   site.where(slug: slug_or_content_type).first
            # else
            #   slug_or_content_type
            # end
            raise 'TODO by_slug'
          end

        end

      end
    end
  end
end
