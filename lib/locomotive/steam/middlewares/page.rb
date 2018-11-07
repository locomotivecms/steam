module Locomotive::Steam
  module Middlewares

    # Retrieve a page from the path and the locale previously
    # fetched from the request.
    #
    class Page < ThreadSafe

      include Concerns::Helpers

      def _call
        return env['steam.page'] if env['steam.page']

        if page = fetch_page
          if !page.not_found?
            log "Found page \"#{page.title}\" [#{page.fullpath}]"
          else
            ActiveSupport::Notifications.instrument('steam.render.page_not_found', path: path, locale: locale, default_locale: default_locale)
            log "Page not found, rendering the 404 page.".magenta
          end
        end

        env['steam.page'] = page
      end

      protected

      def fetch_page
        page = site.routes.present? ? fetch_page_from_routes : nil

        # if we don't find it from the site routes, try with the paths
        page ||= fetch_page_from_paths

        # make sure the page can be displayed, otherwise, display a nice 404 error page
        if page && (page.published? || page.not_found? || live_editing?)
          page
        else
          page_finder.find('404')
        end
      end

      def fetch_page_from_routes
        site.routes.each do |definition|
          route, handle = definition['route'], definition['page_handle']

          _route = route.gsub(/:([a-z][a-z0-9_]+)/, '(?<\1>[^\/]+)').gsub(/^\//, '')
          regexp = Regexp.new(/^#{_route}$/i)

          if (matches = path.match(regexp))
            log "Route found! #{route} (#{handle})"

            # we want the named route parameters in the request params object
            # because they will be needed in the liquid template.
            self.merge_with_params(matches.named_captures)

            return page_finder.by_handle(handle, false)
          end
        end

        nil # out of luck, find another way to get the page
      end

      def fetch_page_from_paths
        page_finder.match(path).tap do |pages|
          if pages.size > 1
            self.log "Found multiple pages: #{pages.map(&:title).join(', ')}"
          end
        end.first
      end

      def page_finder
        services.page_finder
      end

    end

  end
end
