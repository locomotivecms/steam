module Locomotive
  module Steam
    module Repositories

      class Page < Struct.new(:site)

        def all(conditions = {})
          site.pages.ordered_pages(conditions)
        end

        def by_handle(handle)
          site.pages.where(handle: handle).first
        end

        def by_fullpath(path)
          site.pages.where(fullpath: path).first
        end

        def root
          site.pages.root.first
        end

        def parent_of(page)
          page.parent
        end

        def ancestors_of(page)
          page.ancestors_and_self
        end

        def children_of(page)
          page.children
        end

        def editable_elements_of(page)
          page.editable_elements
        end

        def editable_element_for(page, block, slug)
          page.editable_elements.where(block: block, slug: slug).first
        end

      end

    end
  end
end
