module Locomotive::Steam
  module Models

    class I18nField

      attr_reader :name, :translations

      def initialize(name, translations)
        @name = name

        if translations.respond_to?(:fetch)
          @translations = translations.with_indifferent_access
        else
          @translations = Hash.new { translations }
        end
      end

      def [](locale)
        @translations[locale]
      end

      def values
        @translations.values
      end

    end

  end
end
