require 'sanitize'

module Locomotive
  module Steam

    class ContentEntryService

      include Locomotive::Steam::Services::Concerns::Decorator

      attr_accessor_initialize :content_type_repository, :repository, :locale

      def all(type_slug, conditions = {}, as_json = false)
        with_repository(type_slug) do |_repository|
          _repository.all(conditions).map do |entry|
            _decorate(entry, as_json)
          end
        end
      end

      def find(type_slug, id_or_slug, as_json = false)
        with_repository(type_slug) do |_repository|
          entry = _repository.by_slug(id_or_slug) || _repository.find(id_or_slug)
          _decorate(entry, as_json)
        end
      end

      # Warning: do not work with localized and file fields
      def create(type_slug, attributes, as_json = false)
        with_repository(type_slug) do |_repository|
          entry = _repository.build(clean_attributes(attributes))
          decorated_entry = i18n_decorate { entry }

          if validate(_repository, decorated_entry)
            _repository.create(entry)
          end

          logEntryOperation(type_slug, decorated_entry)

          _json_decorate(decorated_entry, as_json)
        end
      end

      # Warning: do not work with localized and file fields
      def update(type_slug, id_or_slug, attributes, as_json = false)
        with_repository(type_slug) do |_repository|
          entry = _repository.by_slug(id_or_slug) || _repository.find(id_or_slug)
          decorated_entry = i18n_decorate { entry.change(clean_attributes(attributes)) }

          if validate(_repository, decorated_entry)
            _repository.update(entry)
          end

          logEntryOperation(type_slug, decorated_entry)

          _json_decorate(decorated_entry, as_json)
        end
      end

      def update_decorated_entry(decorated_entry, attributes)
        with_repository(decorated_entry.content_type) do |_repository|
          entry = decorated_entry.__getobj__

          puts clean_attributes(attributes).inspect

          entry.change(clean_attributes(attributes))

          _repository.update(entry)

          logEntryOperation(decorated_entry.content_type.slug, decorated_entry)

          decorated_entry
        end
      end

      def delete(type_slug, id_or_slug)
        with_repository(type_slug) do |_repository|
          entry = _repository.by_slug(id_or_slug) || _repository.find(id_or_slug)
          _repository.delete(entry)
        end
      end

      def get_type(slug)
        return nil if slug.blank?

        content_type_repository.by_slug(slug)
      end

      def logger
        Locomotive::Common::Logger
      end

      private

      def logEntryOperation(type_slug, entry)
        if (json = entry.as_json)['errors'].blank?
          logger.info "[#{type_slug}] Entry persisted with success. #{json}"
        else
          logger.error "[#{type_slug}] Failed to persist entry. #{json}"
        end
      end

      def with_repository(type_or_slug)
        type = type_or_slug.respond_to?(:fields) ? type_or_slug : get_type(type_or_slug)

        return if type.nil?

        yield(repository.with(type))
      end

      def _decorate(entry, as_json)
        decorated_entry = i18n_decorate { entry }
        _json_decorate(decorated_entry, as_json)
      end

      def _json_decorate(entry, as_json)
        as_json ? entry.as_json : entry
      end

      def clean_attributes(attributes)
        attributes.each do |key, value|
          next unless value.is_a?(String)
          attributes[key] = Sanitize.clean(value, Sanitize::Config::BASIC)
        end
        attributes
      end

      def validate(_repository, entry)
        # simple validations (existence of values) first
        entry.valid?

        # check if the entry has unique values for its
        # fields marked as unique
        content_type_repository.look_for_unique_fields(entry.content_type).each do |name, _|
          if _repository.exists?(name => entry.send(name))
            entry.errors.add(name, :unique)
          end
        end

        entry.errors.empty?
      end

    end

  end
end

