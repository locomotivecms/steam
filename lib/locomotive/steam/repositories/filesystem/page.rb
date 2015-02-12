module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Page < Struct.new(:loader, :site, :current_locale)

          include Concerns::Queryable

          set_collection model: Filesystem::Models::Page, sanitizer: Filesystem::Sanitizers::Page

          # Engine: site.pages.ordered_pages(conditions)
          def all(conditions = {})
            raise 'TODO all'
          end

          # Engine: site.pages.where(handle: handle).first
          def by_handle(handle)
            raise 'TODO by_handle'
          end

          def by_fullpath(path)
            query { where(fullpath: path) }.first
          end

          def matching_fullpath(list)
            query { where('fullpath.in' => list) }.all
          end

          def template_for(entry, handle = nil)
            raise 'TODO template_for'
            # criteria = site.pages.where(target_klass_name: entry.class.to_s, templatized: true)
            # criteria = criteria.where(handle: handle) if handle
            # criteria.first.tap do |page|
            #   page.content_entry = entry if page
            # end
          end

          def root
            query { where(depth: 1, 'slug.ne' => nil) }.all
          end

          # Engine: page.parent
          def parent_of(page)
            raise 'TODO parent_of'
          end

          # Engine: page.ancestors_and_self
          def ancestors_of(page)
            raise 'TODO ancestors_of'
          end

          # Engine: page.children
          def children_of(page)
            query { where(depth: 1, 'slug.ne' => nil) }.all
          end

          # Engine: page.editable_elements
          def editable_elements_of(page)
            page.editable_elements.values
          end

          # Engine: page.editable_elements.where(block: block, slug: slug).first
          def editable_element_for(page, block, slug)
            if elements = page.editable_elements
              name = [block, slug].compact.join('/')
              elements[name]
            else
              nil
            end
          end

        end

      end
    end
  end
end
