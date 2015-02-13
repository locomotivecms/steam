module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Concerns

          module Queryable

            extend ActiveSupport::Concern

            def query(*args, &block)
              _locale = respond_to?(:current_locale) ? current_locale : nil
              MemoryAdapter::Query.new(memoized_collection(*args), _locale, &block)
            end

            private

            def memoized_collection(*args)
              return @collection if @collection

              @collection = collection(*args)
            end

            def collection(*args)
              _collection = loader.list_of_attributes(*args).map do |attributes|
                collection_options[:model].new(attributes)
              end

              sanitize!(_collection)
            end

            def sanitize!(collection)
              sanitizer.try(:apply_to, collection) || collection
            end

            def sanitizer
              return unless (klass = collection_options[:sanitizer])
              klass.new(site.default_locale, site.locales)
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
