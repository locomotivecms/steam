module Locomotive::Steam
  module Middlewares

    # When rendering the page, the developer can stop it at anytime by
    # raising an RedirectionException exception. The exception message holds
    # the url we want the user to be redirected to.
    # This is specifically used by the authorize liquid tag.
    #
    class Redirection < ThreadSafe

      include Concerns::Helpers

      def _call
        begin
          self.next
        rescue Locomotive::Steam::RedirectionException => e
          redirect_to e.url, e.permanent ? 301 : 302
        end
      end

    end
  end

end
