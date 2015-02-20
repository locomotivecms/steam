module Locomotive::Steam
  module Middlewares

    # Set the locale from the path if possible or use the default one
    #
    # Examples:
    #
    #   /fr/index   => locale = :fr
    #   /fr/        => locale = :fr
    #   /index      => locale = :en (default one)
    #
    # The
    #
    class Locale < ThreadSafe

      include Helpers

      def _call
        locale = extract_locale

        log "Detecting locale #{locale.upcase}"

        I18n.with_locale(locale) do
          self.next
        end
      end

      protected

      def extract_locale
        _locale = params[:locale] || default_locale
        _path   = request.path_info

        if _path =~ /^\/(#{site.locales.join('|')})+(\/|$)/
          _locale  = $1
          _path    = _path.gsub($1 + $2, '')

          # let the other middlewares that the locale was
          # extracted from the path.
          env['steam.locale_in_path'] = true
        end

        env['steam.path']   = _path
        env['steam.locale'] = services.current_locale = _locale
      end

    end
  end
end
