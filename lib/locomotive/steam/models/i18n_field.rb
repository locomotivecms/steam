module Locomotive::Steam
  module Models

    class I18nField

      attr_reader :name, :translations

      def initialize(name, translations)
        @name = name

        @translations = (if translations.respond_to?(:fetch)
          translations
        else
          Hash.new { translations }
        end).with_indifferent_access
      end

      def [](locale)
        @translations[locale]
      end

      def []=(locale, value)
        @translations[locale] = value
      end

      def values
        @translations.values
      end

      def each(&block)
        @translations.each(&block)
      end

      alias :__translations__ :translations

    end

  end
end
