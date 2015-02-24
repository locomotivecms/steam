module Locomotive
  module Steam

    class PageRepository

      include Models::Repository

      # Entity mapping
      mapping :pages, entity: Page do
        localized_attributes :title, :slug, :permalink, :template, :template_path, :redirect_url, :fullpath, :seo_title, :meta_description, :meta_keywords

        # embedded association
        association :editable_elements, EditableElementRepository
      end

      def all(conditions = {})
        query do
          where(conditions || {}).
            order_by(depth: :asc, position: :asc)
        end.all
      end

      def by_handle(handle)
        query { where(handle: handle) }.first
      end

      def by_fullpath(path)
        query { where(fullpath: path) }.first
      end

      def matching_fullpath(list)
        all('fullpath.in' => list)
      end

      # Engine: ??? [TODO]
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

      def parent_of(page)
        return nil if page.nil? || page.index?
        query { where(_id: page.parent_id) }.first
      end

      # Note: Ancestors and self
      def ancestors_of(page)
        return [] if page.nil?
        all('_id.in' => page.parent_ids + [page._id])
      end

      def children_of(page)
        return [] if page.nil?
        all(parent_id: page._id)
      end

      def editable_elements_of(page)
        return nil if page.nil?
        page.editable_elements
      end

      def editable_element_for(page, block, slug)
        return nil if page.nil?
        page.editable_elements.first do
          where(block: block, slug: slug)
        end
      end

    end

  end
end
