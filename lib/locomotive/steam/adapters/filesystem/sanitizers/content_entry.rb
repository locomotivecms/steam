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
              set_id(entry)
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

          def set_id(entry)
            if (slug = entry[:_slug]).respond_to?(:translations)
              entry[:_id] = slug[locale]
            else
              entry[:_id] = slug
            end
          end

          def set_slug(entry, dataset)
            if entry._label.respond_to?(:translations) # localized?
              entry._label.each do |locale, label|
                entry[:_slug][locale] ||= slugify(entry._id, label, dataset, locale)
              end
            else
              # Note: replace the translations of the I18nField by a string
              entry[:_slug].translations = slugify(entry._id, entry._label, dataset)
            end
          end

          def slugify(id, label, dataset, locale = nil)
            base, index = label.permalink(false), nil
            _slugify = -> (i) { [base, i].compact.join('-') }

            while !is_slug_unique?(id, _slugify.call(index), dataset, locale)
              index = index ? index + 1 : 1
            end

            _slugify.call(index)
          end

          def is_slug_unique?(id, slug, dataset, locale)
            dataset.query(locale) { where(_slug: slug, k(:_id, :ne) => id) }.first.nil?
          end

        end

      end
    end
  end
end
