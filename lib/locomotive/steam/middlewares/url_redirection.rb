module Locomotive::Steam
  module Middlewares

    # If an old URL has been found among the site url_redirections hash,
    # perform a 310 redirection to the new URL.
    # It is highly useful when the site existed before but was ran by another system.
    #
    # See the specs (spec/unit/middlewares/url_redirection_spec.rb) for more details.
    #
    class UrlRedirection < ThreadSafe

      include Helpers

      def _call
        if url = redirect_url
          redirect_to url
        end
      end

      protected

      def redirect_url
        return false if site.url_redirections.nil? || site.url_redirections.size == 0

        site.url_redirections.to_h[request.env['locomotive.path'] || request.fullpath]
      end

    end
  end

end
