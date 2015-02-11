require_relative 'models/page'
require_relative 'sanitizers/page'

module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Page < Struct.new(:site, :current_locale)

          def all(conditions = {})
            raise 'TODO'
            # site.pages.ordered_pages(conditions)
          end

          def by_handle(handle)
            raise 'TODO'
            # site.pages.where(handle: handle).first
          end

          def by_fullpath(path)
            MemoryAdapter::Query.new(collection, current_locale) do
              where(:fullpath => path)
            end.first
          end

          def matching_fullpath(list)
            MemoryAdapter::Query.new(collection, current_locale) do
              where('fullpath.in' => list)
            end.all
          end

          def template_for(entry, handle = nil)
            # criteria = site.pages.where(target_klass_name: entry.class.to_s, templatized: true)
            # criteria = criteria.where(handle: handle) if handle
            # criteria.first.tap do |page|
            #   page.content_entry = entry if page
            # end
          end

          def root
            # site.pages.root.first
          end

          def parent_of(page)
            # page.parent
          end

          def ancestors_of(page)
            # page.ancestors_and_self
          end

          def children_of(page)
            # page.children
          end

          def editable_elements_of(page)
            # page.editable_elements
          end

          def editable_element_for(page, block, slug)
            # page.editable_elements.where(block: block, slug: slug).first
          end

          private

          def collection
            return @collection if @collection

            loader  = MemoryAdapter::YAMLLoader.instance
            list    = loader.tree('app/views/pages')

            @collection = list.map do |attributes|
              Models::Page.new(attributes)
            end

            Sanitizers::Page.new(@collection, site.locales).apply

            @collection
          end

        end

      end
    end
  end
end
