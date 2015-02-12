module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Translation < Struct.new(:site)

          # include Concerns::Queryable

          # Engine: site.translations.where(key: input).first
          def find(key)
            query { where(key: key) }
          end

          private

          def query(&block)
            MemoryAdapter::Query.new(collection, current_locale, &block)
          end

          def collection
            return @collection if @collection

            @collection = loader.list_of_attributes.map do |attributes|
              Filesystem::Models::Translation.new(attributes)
            end

            Filesystem::Sanitizers::Page.new(@collection, site.locales).apply
          end

        end

      end
    end
  end
end
