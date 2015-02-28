module Locomotive
  module Steam

    class SiteRepository

      include Models::Repository

      # Entity mapping
      mapping :sites, entity: Site do
        localized_attributes :seo_title, :meta_description, :meta_keywords
      end

      def by_handle_or_domain(handle, domain)
        if handle.nil?
          query { where('domains.in' => domain) }.first
        else
          query { where(handle: handle) }.first
        end
      end

    end

  end
end
