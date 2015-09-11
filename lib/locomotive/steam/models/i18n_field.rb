module Locomotive::Steam
  module Models

    class I18nField

      extend Forwardable

      def_delegators :@translations, :values, :blank?

      attr_reader :name, :translations

      def initialize(name, translations)
        @name = name
        self.translations = translations
      end

      def [](locale)
        @translations[locale]
      end

      def []=(locale, value)
        @translations[locale] = value
      end

      def translations=(translations)
        @translations = (if translations.respond_to?(:fetch)
          translations
        else
          Hash.new { translations }
        end).with_indifferent_access
      end

      def each(&block)
        @translations.each(&block)
      end

      alias :__translations__ :translations

      alias :to_hash :translations

      def serialize(attributes)
        attributes[@name] = @translations
      end

    end

  end
end
