module Locomotive
  module Steam

    class SiteRepository

      include Steam::Repository

      mapping :sites, entity: Steam::Entities::Site do
        set_localized_attributes :seo_title, :meta_description, :meta_keywords
      end

      def by_handle_or_domain(handle, domain)
        if handle.nil?
          query { where(handle: handle) }.first
        else
          query { where('domains.in' => [*domain]) }.first
        end
      end

    end

  end
end
