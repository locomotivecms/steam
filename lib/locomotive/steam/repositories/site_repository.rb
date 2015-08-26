module Locomotive
  module Steam

    class SiteRepository

      include Models::Repository

      # Entity mapping
      mapping :sites, entity: Site do
        localized_attributes :seo_title, :meta_description, :meta_keywords
      end

      def by_domain(domain)
        first { where(k(:domains, :in) => [*domain]) }
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
