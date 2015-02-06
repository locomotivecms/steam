module Locomotive
  module Steam
    module Repositories

      class Page < Struct.new(:site)

        def by_handle(handle)
          site.pages.where(handle: handle).first
        end

        def parent_of(page)
          page.parent
        end

        def by_fullpath(path)
          site.pages.where(fullpath: path).first
        end

        def root
          site.pages.root.first
        end

        def children_of(page)
          page.children
        end

        def editable_element_for(page, block, slug)
          page.editable_elements.where(block: block, slug: slug).first
        end

      end

    end
  end
end
