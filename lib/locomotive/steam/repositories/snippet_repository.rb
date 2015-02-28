module Locomotive
  module Steam

    class SnippetRepository

      include Models::Repository

      # Entity mapping
      mapping :snippets, entity: Snippet do
        localized_attributes :template_path, :template
      end

      def by_slug(slug)
        query { where(slug: slug) }.first
      end

    end
  end
end
