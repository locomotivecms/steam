module Locomotive::Steam
  module Middlewares

    # Fetch a site using the site_finder service
    #
    class Site < ThreadSafe

      def _call
        site = services.site_finder.find
        env['steam.site'] = services.repositories.current_site = site
      end

    end

  end
end
