module Locomotive
  module Steam
    module Repositories

      class Snippet < Struct.new(:site)

        def by_slug(slug)
          site.snippets.where(slug: slug).first
        end

      end

    end
  end
end
