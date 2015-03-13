module Locomotive
  module Steam

    class PageRepository

      include Models::Repository

      # Entity mapping
      mapping :pages, entity: Page do
        localized_attributes :title, :slug, :permalink, :source, :raw_template, :template_path, :redirect_url, :fullpath, :seo_title, :meta_description, :meta_keywords

        embedded_association :editable_elements, EditableElementRepository
      end

      def all(conditions = {})
        query do
          where(conditions || {}).
            order_by(depth: :asc, position: :asc)
        end.all
      end

      def by_handle(handle)
        first { where(handle: handle) }
      end

      def by_fullpath(path)
        first { where(fullpath: path) }
      end

      def matching_fullpath(list)
        all(k(:fullpath, :in) => list)
      end

      def template_for(entry, handle = nil)
        conditions = { templatized?: true, content_type: entry.try(:content_type_slug) }

        conditions[:handle] = handle if handle

        query { where(conditions) }.first.tap do |page|
          page.content_entry = entry if page
        end
      end

      def root
        first { where(fullpath: 'index') }
      end

      def parent_of(page)
        return nil if page.nil? || page.index?
        first { where(_id: page.parent_id) }
      end

      # Note: Ancestors and self
      def ancestors_of(page)
        return [] if page.nil?
        all(k(:_id, :in) => page.parent_ids + [page._id])
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
