module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers

        class ContentEntry

          include Adapters::Filesystem::Sanitizer

          def apply_to_entity(entity)
            super
            add_label(entity)
          end

          def apply_to_dataset(dataset)
            dataset.all.each do |entry|
              set_slug(entry, dataset)
            end
          end

          private

          def add_label(entry)
            value = entry.attributes.delete(:_label)
            name  = entry.content_type.label_field_name

            if entry.attributes[name].respond_to?(:translations) # localized?
              entry.attributes[name][default_locale] = value
            else
              entry.attributes[name] ||= value
            end
          end

          def set_slug(entry, dataset)
            if entry._label.respond_to?(:translations) # localized?
              entry[:_slug] ||= {}
              entry._label.each do |locale, label|
                entry[:_slug][locale] ||= slugify(label, dataset, locale)
              end
            else
              entry[:_slug] ||= slugify(entry._label, dataset)
            end
          end

          def slugify(label, dataset, locale = nil)
            base, index = label.permalink(false), nil
            _slugify = -> (i) { [base, i].compact.join('-') }

            while !is_slug_unique?(_slugify.call(index), dataset, locale)
              index = index ? index + 1 : 1
            end

            _slugify.call(index)
          end

          def is_slug_unique?(slug, dataset, locale)
            dataset.query(locale) { where(_slug: slug) }.first.nil?
            # Filesystem::MemoryAdapter::Query.new(collection, locale) do
            #   where(_slug: slug)
            # end.first.nil?
          end

        end

      end
    end
  end
end





# module Locomotive
#   module Steam
#     module Repositories
#       module Filesystem
#         module Sanitizers

#           class ContentEntry < Struct.new(:default_locale, :locales)

#             def apply_to(collection)
#               collection.each do |entry|
#                 set_content_type(entry)
#                 add_label(entry)
#                 set_slug(entry, collection)
#               end
#             end

#             def set_slug(entry, collection)
#               if entry._label.is_a?(Hash)
#                 entry[:_slug] ||= {}
#                 entry._label.each do |locale, label|
#                   entry[:_slug][locale] ||= slugify(label, collection, locale)
#                 end
#               else
#                 entry[:_slug] ||= slugify(entry._label, collection)
#               end
#             end

#             def slugify(label, collection, locale = nil)
#               base, index = label.permalink(false), nil
#               _slugify = -> (i) { [base, i].compact.join('-') }

#               while !is_slug_unique?(_slugify.call(index), collection, locale)
#                 index = index ? index + 1 : 1
#               end

#               _slugify.call(index)
#             end

#             def is_slug_unique?(slug, collection, locale)
#               Filesystem::MemoryAdapter::Query.new(collection, locale) do
#                 where(_slug: slug)
#               end.first.nil?
#             end

#             def set_content_type(entry)
#               entry.content_type = entry.attributes.delete(:content_type)
#             end

#             def add_label(entry)
#               value = entry.attributes.delete(:_label)
#               name  = entry.content_type.label_field_name

#               if entry.attributes[name].is_a?(Hash) # localized?
#                 entry.attributes[name][default_locale] = value
#               else
#                 entry.attributes[name] ||= value
#               end
#             end

#           end

#         end
#       end
#     end
#   end
# end
