module Locomotive::Steam
  module Middlewares

    # Set the locale from the path if possible or use the default one
    # Examples:
    #   /fr/index   => locale = :fr
    #   /fr/        => locale = :fr
    #   /index      => locale = :en (default one)
    #
    class Locale < ThreadSafe

      include Helpers

      def _call
        set_locale
      end

      protected

      def set_locale
        _locale = default_locale
        _path   = path

        if _path =~ /^(#{site.locales.join('|')})+(\/|$)/
          _locale  = $1
          _path    = _path.gsub($1 + $2, '')
          _path    = 'index' if _path.blank?
        end

        log "Detecting locale #{_locale.upcase}"

        services.current_locale = _locale

        env['steam.locale']     = _locale
        env['steam.path']       = _path
      end

    end
  end
end
