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

        redirect_to_first_domain_if_enabled(site)
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

      def redirect_to_first_domain_if_enabled(site)
        if redirect_to_first_domain?(site)
          klass = request.scheme == 'https' ? URI::HTTPS : URI::HTTP
          redirect_to klass.build(
            host:   site.domains.first,
            port:   [80, 443].include?(request.port) ? nil : request.port,
            path:   request.path,
            query:  request.query_string.present? ? request.query_string : nil).to_s
        end
      end

      def redirect_to_first_domain?(site)
        # the site parameter can be an instance of Locomotive::Steam::Services::Defer and
        # so comparing just site may not be reliable.
        !env['steam.is_default_host'] &&
        site.try(:redirect_to_first_domain) &&
        site.domains.first != request.host
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
