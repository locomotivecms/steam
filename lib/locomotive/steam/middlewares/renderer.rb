module Locomotive::Steam
  module Middlewares

    class Renderer < ThreadSafe

      include Concerns::Helpers
      include Concerns::Rendering

      def _call
        if page
          render_page_or_redirect
        else
          render_missing_404
        end
      end

      private

      def render_page_or_redirect
        if page.redirect?
          redirect_to(page.redirect_url, page.redirect_type)
        else
          render_page
        end
      end

    end

  end
end
