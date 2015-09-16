module Locomotive
  module Steam

    class SnippetFinderService

      include Locomotive::Steam::Services::Concerns::Decorator

      attr_accessor_initialize :repository

      def find(slug)
        decorate do
          repository.by_slug(slug)
        end
      end

    end

  end
end
