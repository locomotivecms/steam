module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Snippet < Struct.new(:loader, :site, :current_locale)

          include Locomotive::Steam::Repositories::Filesystem::Concerns::Queryable

          set_collection model: Filesystem::Models::Snippet, sanitizer: Filesystem::Sanitizers::Snippet

          def by_slug(slug)
            query { where(slug: slug) }.first
          end

        end

      end
    end
  end
end
