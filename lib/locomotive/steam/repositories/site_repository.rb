module Locomotive
  module Steam

    class SiteRepository

      include Models::Repository

      # Entity mapping
      mapping :sites, entity: Site do
        localized_attributes :seo_title, :meta_description, :meta_keywords
      end

      def by_domain(domain)
        conditions = { k(:domains, :in) => [*domain] }
        first { where(conditions) }
      end

      def by_handle_or_domain(handle, domain)
        if handle.nil?
          by_domain(domain)
        else
          first { where(handle: handle) }
        end
      end

    end

  end
end
