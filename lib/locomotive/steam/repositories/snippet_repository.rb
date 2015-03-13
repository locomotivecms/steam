module Locomotive
  module Steam

    class SnippetRepository

      include Models::Repository

      # Entity mapping
      mapping :snippets, entity: Snippet do
        localized_attributes :template_path, :template, :source
      end

      def by_slug(slug)
        first { where(slug: slug) }
      end

    end
  end
end
