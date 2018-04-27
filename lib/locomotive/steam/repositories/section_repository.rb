module Locomotive
  module Steam
    class SectionRepository

      include Models::Repository

      mapping :sections, entity: Section

      def by_slug(slug)
        first { where(slug: slug) }
      end
    end
  end
end
