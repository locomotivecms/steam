module Locomotive::Steam
  module Middlewares

    # Fetch a site using the site_finder service
    #
    class Site < ThreadSafe

      def _call
        env['steam.site'] ||= services.site_finder.find
        services.repositories.current_site = env['steam.site']
      end

    end

  end
end
