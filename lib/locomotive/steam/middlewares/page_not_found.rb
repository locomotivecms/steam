module Locomotive::Steam
  module Middlewares

    # When rendering the page, the developer can stop it at anytime by
    # raising an PageNotFoundException exception.
    # Instead of the page, the 404 not found page will be rendered.
    #
    # This is particularly helpful with the dynamic routing feature
    # to avoid duplicated page content (different urls, same HTTP 200 code but same blank page).
    #
    class PageNotFound < ThreadSafe

      include Concerns::Helpers
      include Concerns::Rendering

      def _call
        begin
          self.next
        rescue Locomotive::Steam::PageNotFoundException => e
          # fetch the 404 error page...
          env['steam.page'] = page_finder.find('404')

          # ... and render it instead
          render_page
        end
      end

      private

      def page_finder
        services.page_finder
      end

    end
  end

end
