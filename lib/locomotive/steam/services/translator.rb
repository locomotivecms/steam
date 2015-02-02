module Locomotive
  module Steam
    module Services

      class Translator < Struct.new(:repository, :default_locale)

        # Return the translation described by a key.
        #
        # @param [ String ] key The key of the translation.
        # @param [ String ] locale The locale we want the translation in
        # @param [ String ] scope If specified, instead of looking in the translations, it will use I18n instead.
        #
        # @return [ String ] the translated text or nil if not found
        #
        def translate(input, locale, scope = nil)
          if scope.blank?
            values = repository.find(input).try(:values) || {}

            values[locale.to_s] || values[default_locale.to_s]
          else
            I18n.t(input, scope: scope.split('.'), locale: locale)
          end
        end

      end

    end
  end
end
