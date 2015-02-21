module Locomotive::Steam
  module Models

    class Scope < Struct.new(:site, :locale)

      def default_locale
        site.try(:default_locale)
      end

      def locales
        site.try(:locales)
      end

    end

  end
end
