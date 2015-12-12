module Locomotive::Steam
  module Middlewares

    # Hide a site behind a password to prevent public access.
    # If page with the "lock_screen" handle exists, then it
    # will be used to display the login form. Otherwise, a very basic
    # form will be displayed.
    #
    class PrivateAccess < ThreadSafe

      include Helpers

      def _call
        return if env['steam.private_access_disabled']

        if site.private_access
          log "Site with private access"

          if access_granted?
            store_password
          else
            render_response(lock_screen_html, 403)
          end
        end
      end

      private

      def access_granted?
        !submitted_password.blank? && submitted_password == site.password
      end

      def submitted_password
        request.session[:private_access_password] || params[:private_access_password]
      end

      def store_password
        request.session[:private_access_password] = params[:private_access_password] if params[:private_access_password].present?
      end

      def lock_screen_html
<<-HTML
<html>
  <title>#{site.name} - Password protected</title>
  <style>
    @import url(http://fonts.googleapis.com/css?family=Open+Sans:400,700);
    body { background: #f8f8f8; font-family: "Open Sans", sans-serif; font-size: 12px; }
    form { position: relative; top: 50%; width: 300px; margin: 0px auto; transform: translateY(-50%); -webkit-transform: translateY(-50%); -ms-transform: translateY(-50%); }
    form p { text-align: center; color: #d9684c; }
    form input[type=password] { border: 2px solid #eee; font-size: 14px; padding: 5px 8px; background: #fff; }
    form input[type=submit] { border: 0 none; padding: 6px 20px; background: #171717; color: #fff; font-size: 14px; text-transform: none; transition: all 100ms ease-in-out; cursor: pointer; }
    form input[type=submit]:hover { opacity: .7; }
  }
  </style>
  <body>
    <form action="/#{mounted_on}" method="POST">
      #{'<p>Wrong password</p>' unless submitted_password.blank?}
      <input type="password" name="private_access_password" placeholder="Password" />
      &nbsp;
      <input type="submit" value="Unlock" />
    </form>
  </body>
</html>
HTML
      end

    end

  end
end
