require 'sanitize'

module Locomotive
  module Steam
    module Services

      class EntrySubmission < Struct.new(:content_type_repository, :repository, :current_locale)

        include Locomotive::Steam::Services::Concerns::Decorator

        def submit(slug, attributes = {})
          type = get_type(slug)

          return nil if type.nil?

          clean_attributes(attributes)

          build_entry(type, attributes) do |entry|
            if validate(entry)
              repository.persist(entry)
            end
          end
        end

        def find(type_slug, slug)
          type = get_type(type_slug)

          return nil if type.nil?

          i18n_decorate { repository.by_slug(type, slug) }
        end

        def to_json(entry)
          return nil if entry.nil?

          # default values
          hash = { _slug: entry._slug, content_type_slug: entry.content_type_slug }

          # dynamic attributes
          content_type_repository.fields_for(entry.content_type).each do |field|
            next if %w(belongs_to has_many many_to_many).include?(field.type.to_s)

            hash[field.name] = entry.send(field.name)
          end

          # errors
          hash[:errors] = entry.errors.messages unless entry.errors.empty?

          hash.to_json
        end

        private

        def get_type(slug)
          return nil if slug.blank?

          content_type_repository.by_slug(slug)
        end

        def build_entry(type, attributes, &block)
          i18n_decorate { repository.build(type, attributes) }.tap do |entry|
            yield(entry)
          end
        end

        def validate(entry)
          # simple validations (existence of values) first
          entry.valid?

          # check if the entry has unique values for its
          # fields marked as unique are really
          content_type_repository.look_for_unique_fields(entry.content_type).each do |name, field|
            if repository.exists?(entry.content_type, name, entry.send(name))
              entry.errors.add(name, :unique)
            end
          end

          entry.errors.empty?
        end

        def clean_attributes(attributes)
          attributes.each do |key, value|
            next unless value.is_a?(String)
            attributes[key] = Sanitize.clean(value, Sanitize::Config::BASIC)
          end
        end

      end

    end
  end
end
