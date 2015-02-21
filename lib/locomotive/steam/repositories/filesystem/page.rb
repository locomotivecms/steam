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
            all('fullpath.in' => list)
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

            # TODO: parent_id property
            segments = localized_attribute(page, :fullpath).split('/')
            path = segments[0..-2].join('/')
            path = 'index' if path.blank?

            by_fullpath(path)
          end

          # Engine: page.ancestors_and_self
          def ancestors_of(page)
            return [] if page.nil?

            # Example: foo/bar/test
            # ['foo', 'foo/bar', 'foo/bar/test']
            segments = localized_attribute(page, :fullpath).split('/')
            paths = 0.upto(segments.size - 1).map { |i| segments[0..i].join('/') }

            all('fullpath.in' => ['index'] + paths)
          end

          # Engine: page.children
          def children_of(page)
            return [] if page.nil?

            conditions = { 'slug.ne' => nil, depth: page.depth + 1 }

            unless page.index?
              conditions[:fullpath] = /^#{localized_attribute(page, :fullpath)}\//
            end

            all(conditions)
          end

          # Engine: page.editable_elements
          def editable_elements_of(page)
            return nil if page.nil?
            localized_attribute(page, :editable_elements).values
          end

          # Engine: page.editable_elements.where(block: block, slug: slug).first
          def editable_element_for(page, block, slug)
            return nil if page.nil?

            if elements = localized_attribute(page, :editable_elements)
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
