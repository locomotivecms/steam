module Locomotive
  module Steam
    module Repositories

      class Page < Struct.new(:site, :locale)

        def all(conditions = {})
          site.pages.ordered_pages(conditions)
        end

        def by_handle(handle)
          site.pages.where(handle: handle).first
        end

        def by_fullpath(path)
          site.pages.where(fullpath: path).first
        end

        def template_for(entry, handle = nil)
          criteria = site.pages.where(target_klass_name: entry.class.to_s, templatized: true)
          criteria = criteria.where(handle: handle) if handle
          criteria.first.tap do |page|
            page.content_entry = entry if page
          end
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
