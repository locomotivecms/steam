module Locomotive::Steam
  module Middlewares

    # If an account defined by a content type was impersonated from the back-office,
    # load the entry and sign her/him in automatically.
    #
    # Besides, display a small banner at the top of the page in order to let
    # the administrator stop the impersonation of the account.
    #
    class ImpersonatedEntry < ThreadSafe

      include Concerns::Helpers
      include Concerns::AuthHelpers

      def _call
        if params[:impersonating] == 'stop'
          # sign out the current user
          store_authenticated(nil)

          # leave the impersonating mode
          request.session[:authenticated_impersonation] == '0'

          # redirect the user to the same page
          redirect_to path, 302
        elsif authenticated? && is_impersonating?
          # useful if other middlewares need this information
          env['steam.impersonating_authenticated_entry'] = true

          # again, useful if the developer needs to add a "impersonate" button
          # directly in her/his website in any Liquid template
          liquid_assigns["is_impersonating_current_#{authenticated_entry_type.singularize}"] = true
        end
      end

      def next
        response = super

        if authenticated? && is_impersonating? && html?
          # get the authenticated entry from the Auth middleware
          entry = env['steam.authenticated_entry']

          # modify the HTML body by adding a banner at the bottom of the page
          status, headers, body = response
          [status, headers, [body.first.gsub(/(<body[^>]*>)/, '\1' +  banner_html(entry))]]
        else
          response
        end
      end

      private

      def is_impersonating?
        request.session[:authenticated_impersonation] == '1'
      end

      def banner_html(entry)
        <<-HTML
<div
  class="locomotive-impersonating-banner"
  style="position: fixed; bottom: 0; left: 0; z-index: 9999; width: 100%;background: #61D5AB; text-align: center; color: #fff; padding: 1rem 0rem;"
>
  You're impersonating <b>#{entry._label}</b>.
  <a href="?impersonating=stop" style="color: #fff; text-decoration: underline">
    Stop impersonating
  </a>
</div>
        HTML
      end

    end

  end
end
