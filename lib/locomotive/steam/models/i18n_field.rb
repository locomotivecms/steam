module Locomotive::Steam
  module Models

    class I18nField

      extend Forwardable

      def_delegators :@translations, :values, :default

      attr_reader :name, :translations

      def initialize(name, translations)
        @name = name
        self.translations = translations
      end

      def initialize_copy(field)
        super
        self.translations = field.translations.dup
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
          Hash.new(translations)
        end).with_indifferent_access
      end

      def each(&block)
        @translations.each(&block)
      end

      def blank?
        @translations.default.blank? && (
          @translations.blank? ||
          @translations.values.all? { |v| v.blank? }
        )
      end

      def apply(&block)
        if default
          @translations = Hash.new(yield(default))
        else
          each do |l, _value|
            self[l] = block.arity == 2 ? yield(_value, l) : yield(_value)
          end
        end
        self
      end

      def duplicate(new_name)
        self.class.new(new_name, self.translations)
      end

      alias :__translations__ :translations

      alias :to_hash :translations

      def serialize(attributes)
        attributes[@name] = @translations
      end

      def to_json
        to_hash.to_json
      end

    end

  end
end
