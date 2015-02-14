module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Page < Struct.new(:loader, :site, :current_locale)

          include Concerns::Queryable

          set_collection model: Filesystem::Models::Page, sanitizer: Filesystem::Sanitizers::Page

          # Engine: site.pages.ordered_pages(conditions)
          def all(conditions = {})
            default_order = 'depth_and_position asc'
            query { where(conditions || {}).order_by(default_order) }.all
          end

          # Engine: site.pages.where(handle: handle).first
          def by_handle(handle)
            query { where(handle: handle) }.first
          end

          def by_fullpath(path)
            query { where(fullpath: path) }.first
          end

          def matching_fullpath(list)
            query { where('fullpath.in' => list) }.all
          end

          # Engine: ???
          def template_for(entry, handle = nil)
            conditions = { templatized?: true, content_type: entry.try(:content_type_slug) }

            conditions[:handle] = handle if handle

            query { where(conditions) }.first.tap do |page|
              page.content_entry = entry if page
            end
          end

          def root
            query { where(fullpath: 'index') }.first
          end

          # Engine: page.parent
          def parent_of(page)
            return nil if page.nil? || page.index?

            segments = localized_attribute(page, :fullpath).split('/')
            path = segments[0..-2].join('/')
            path = 'index' if path.blank?

            by_fullpath(path)
          end

          # Engine: page.ancestors_and_self
          def ancestors_of(page)
            return [] if page.nil?
            return [page] if page.index?

            # Example: foo/bar/test
            # ['index', 'foo', 'foo/bar', 'foo/bar/test']
            segments = localized_attribute(page, :fullpath).split('/')
            paths = ['index'].tap do |_paths|
              0.upto(segments.size - 1) do |i|
                _paths << segments[0..i].join('/')
              end
            end

            query { where('fullpath.in' => paths) }.all
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
