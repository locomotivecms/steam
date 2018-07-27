module Locomotive::Steam
  module Middlewares

    # Redirect to the resource (page, templatized page with a content entry)
    # based on the encoded link in the url.
    # The link is encoded by the UrlPicker component (engine).
    #
    # For SEO purpose, the encoded link shouldn't be shared. It's just for internal purposes.
    #
    # Example:
    #
    # /_locomotive-link/eyJ0eXBlIjoiX2V4dGVybmFsIiwidmFsdWUiOiJodHRwczovL3d3dy5ub2NvZmZlZS5mciIsImxhYmVsIjpbImV4dGVybmFsIiwiaHR0cHM6Ly93d3cubm9jb2ZmZWUuZnIiXX0
    #
    # will redirect (302) to https://www.nocoffee.fr
    #
    class EncodedLinkRedirection < ThreadSafe

      include Concerns::Helpers

      PATH_REGEXP = /\/_locomotive-link\/(?<link>[^\"]+)/mo.freeze

      def _call
        if env['PATH_INFO'] =~ PATH_REGEXP
          resource = url_finder.decode_link($~[:link])

          # set the locale
          if resource && resource['locale']
            services.locale = 'fr'
          end

          link, _ = url_finder.url_for(resource)

          redirect_to link, 302
        end
      end

      private

      def url_finder
        services.url_finder
      end

    end
  end
end
