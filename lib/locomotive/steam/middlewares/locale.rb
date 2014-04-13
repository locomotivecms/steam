module Locomotive::Steam
  module Middlewares

    # Set the locale from the path if possible or use the default one
    # Examples:
    #   /fr/index   => locale = :fr
    #   /fr/        => locale = :fr
    #   /index      => locale = :en (default one)
    #
    class Locale < Base

      def _call(env)
        super

        self.set_locale!(env)

        app.call(env)
      end

      protected

      def set_locale!(env)
        locale  = self.mounting_point.default_locale

        if self.path =~ /^(#{self.mounting_point.locales.join('|')})+(\/|$)/
          locale    = $1
          self.path = self.path.gsub($1 + $2, '')
          self.path = 'index' if self.path.blank?
        end

        Locomotive::Mounter.locale = locale
        ::I18n.locale = locale

        self.log "Detecting locale #{locale.upcase}"

        env['steam.locale'] = locale
        env['steam.path']   = self.path
      end

    end
  end
end