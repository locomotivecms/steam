module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Page < Struct.new(:loader, :site, :current_locale)

          def all(conditions = {})
            raise 'TODO all'
            # site.pages.ordered_pages(conditions)
          end

          def by_handle(handle)
            raise 'TODO by_handle'
            # site.pages.where(handle: handle).first
          end

          def by_fullpath(path)
            MemoryAdapter::Query.new(collection, current_locale) do
              where(fullpath: path)
            end.first
          end

          def matching_fullpath(list)
            MemoryAdapter::Query.new(collection, current_locale) do
              where('fullpath.in' => list)
            end.all
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
            raise 'TODO root'
            # site.pages.root.first
          end

          def parent_of(page)
            raise 'TODO parent_of'
            # page.parent
          end

          def ancestors_of(page)
            raise 'TODO ancestors_of'
            # page.ancestors_and_self
          end

          def children_of(page)
            raise 'TODO children_of'
            # page.children
          end

          def editable_elements_of(page)
            raise 'TODO editable_elements_of'
            # page.editable_elements
          end

          def editable_element_for(page, block, slug)
            raise 'TODO editable_element_for'
            # page.editable_elements.where(block: block, slug: slug).first
          end

          private

          def collection
            return @collection if @collection

            @collection = loader.list_of_attributes.map do |attributes|
              Filesystem::Models::Page.new(attributes)
            end

            Filesystem::Sanitizers::Page.new(@collection, site.locales).apply
          end

        end

      end
    end
  end
end
