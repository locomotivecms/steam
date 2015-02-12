module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Concerns

          module Queryable

            extend ActiveSupport::Concern

            def query(&block)
              MemoryAdapter::Query.new(collection, current_locale, &block)
            end

            private

            def collection
              return @collection if @collection

              @collection = loader.list_of_attributes.map do |attributes|
                collection_options[:model].new(attributes)
              end

              if sanitizer = collection_options[:sanitizer]
                sanitizer.new(site.default_locale, site.locales).apply_to(@collection)
              else
                @collection
              end
            end

            module ClassMethods

              def set_collection(options = {})
                class_eval do
                  define_method(:collection_options) { options }
                end
              end

            end

          end

        end
      end
    end
  end
end
