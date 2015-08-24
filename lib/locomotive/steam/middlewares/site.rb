module Locomotive::Steam
  module Middlewares

    # Fetch a site using the site_finder service. Look for an existing
    # site in the rack env variable (context: when launched from the Engine).
    #
    class Site < ThreadSafe

      include Helpers

      def _call
        site = find_site

        no_site! if site.nil?

        # log anyway
        log_site(site)
      end

      private

      def find_site
        if env['steam.site']
          # happens if Steam is running within the Engine
          services.set_site(env['steam.site'])
        else
          env['steam.site'] = services.current_site
        end
      end

      def no_site!
        # render a simple message if the service was not able to find a site
        # based on the request.
        if services.configuration.render_404_if_no_site
          render_response('Hi, we are sorry but no site was found.', 404, 'text/html')
        else
          raise NoSiteException.new
        end
      end

      def log_site(site)
        if site.nil?
          msg = "Unable to find a site, url asked: #{request.url} ".colorize(color: :light_white, background: :red)
        else
          msg = site.name.colorize(color: :light_white, background: :blue)
        end

        log msg, 0
      end

    end

  end
end
