module Locomotive
  module Steam

    class EntrySubmissionService

      attr_accessor_initialize :service

      def submit(type_slug, attributes = {})
        type = service.get_type(type_slug)

        return nil if type.nil? || type.public_submission_enabled == false

        service.create(type, attributes)
      end

      def find(type_slug, slug)
        service.find(type_slug, slug)
      end

      def to_json(entry)
        entry.try(&:to_json)
      end

    end

  end
end

