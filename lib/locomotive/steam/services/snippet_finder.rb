module Locomotive
  module Steam
    module Services

      class SnippetFinder < Struct.new(:repository)

        include Locomotive::Steam::Services::Concerns::Decorator

        def find(slug)
          decorate do
            repository.by_slug(slug)
          end
        end

      end

    end
  end
end
