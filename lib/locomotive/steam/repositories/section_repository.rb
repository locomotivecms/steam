module Locomotive
  module Steam

    class SectionRepository

      include Models::Repository

      # Entity mapping
      mapping :sections, entity: Section do
        localized_attributes :template_path, :template, :source
      end

      def by_slug(slug)
        first { where(slug: slug) }
      end

    end
  end
end
