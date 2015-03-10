module Locomotive
  module Steam

    class TranslatorService < Struct.new(:repository, :current_locale)

      # Return the translation described by a key.
      #
      # @param [ String ] key The key of the translation.
      # @param [ String ] locale The locale we want the translation in
      # @param [ String ] scope If specified, instead of looking in the translations, it will use I18n instead.
      #
      # @return [ String ] the translated text or nil if not found
      #
      def translate(input, locale, scope = nil)
        locale ||= self.current_locale

        if scope.blank?
          values = repository.find(input).try(:values) || {}

          if translation = values[locale.to_s]
            translation
          else
            Locomotive::Common::Logger.warn "Missing translation '#{input}' for the '#{locale}' locale".yellow
            input
          end
        else
          I18n.t(input, scope: scope.split('.'), locale: locale)
        end
      end

    end

  end
end
