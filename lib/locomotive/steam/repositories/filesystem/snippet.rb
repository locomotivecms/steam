module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Snippet < Struct.new(:loader, :site, :current_locale)

          def by_slug(slug)
            MemoryAdapter::Query.new(collection, current_locale) do
              where(slug: slug)
            end.first
          end

          private

          def collection
            return @collection if @collection

            @collection = loader.list_of_attributes.map do |attributes|
              Filesystem::Models::Snippet.new(attributes)
            end

            Filesystem::Sanitizers::Snippet.new(@collection, site.default_locale, site.locales).apply
          end

        end

      end
    end
  end
end
