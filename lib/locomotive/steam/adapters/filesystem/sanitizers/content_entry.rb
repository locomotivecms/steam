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
            dataset.all.each do |entity|
              _apply_to_dataset(entity, dataset)
            end
          end

          def apply_to_entity_with_dataset(entity, dataset)
            # Note: this statement attaches the site to the entity
            apply_to_entity(entity)

            # make sure it gets an unique slug and an _id
            _apply_to_dataset(entity, dataset)
          end

          private

          def _apply_to_dataset(entity, dataset)
            set_slug(entity, dataset)
            set_id(entity)
          end

          def add_label(entity)
            value = entity.attributes.delete(:_label)
            name  = entity.content_type.label_field_name

            if entity.attributes[name].respond_to?(:translations) # localized?
              entity.attributes[name][default_locale] = value
            else
              entity.attributes[name] ||= value
            end
          end

          def set_id(entity)
            if (slug = entity[:_slug]).respond_to?(:translations)
              entity[:_id] = slug[locale]
            else
              entity[:_id] = slug
            end
          end

          def set_slug(entity, dataset)
            if entity._label.respond_to?(:translations) # localized?
              entity._label.each do |locale, label|
                entity[:_slug][locale] ||= slugify(entity._id, label, dataset, locale)
              end
            else
              # Note: replace the translations of the I18nField by a string
              entity[:_slug].translations = slugify(entity._id, entity._label, dataset)
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
