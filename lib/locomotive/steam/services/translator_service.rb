module Locomotive
  module Steam

    class TranslatorService

      attr_accessor_initialize :repository, :current_locale

      # Return the translation described by a key.
      #
      # @param [ String ] key The key of the translation.
      # @param [ Hash ] options This includes the following options: count, locale (The locale we want the translation in), scope (If specified, instead of looking in the translations, it will use I18n instead)
      #
      # @return [ String ] the translated text or nil if not found
      #
      def translate(input, options = {})
        locale  = options['locale'] || self.current_locale
        scope   = options.delete('scope')

        if scope.blank?
          input = "#{input}_#{pluralize_prefix(options['count'])}" if options['count']

          values = find_values_by_key(input)

          # FIXME: important to check if the returned value is nil (instead of nil + false)
          # false being reserved for an existing key but without provided translation)
          if (translation = values[locale.to_s]).present?
            _translate(translation, options)
          else
            Locomotive::Common::Logger.warn "Missing translation '#{input}' for the '#{locale}' locale".yellow
            ActiveSupport::Notifications.instrument('steam.missing_translation', input: input, locale: locale)
            input
          end
        else
          I18n.t(input, scope: scope.split('.'), locale: locale)
        end
      end

      private

      def find_values_by_key(input)
        (@all_values ||= repository.group_by_key)[input] || {}
      end

      def _translate(string, options)
        ::Liquid::Template.parse(string).render(options)
      end

      def pluralize_prefix(count)
        case count.to_i
        when 0 then 'zero'
        when 1 then 'one'
        when 2 then 'two'
        else 'other'
        end
      end

    end

  end
end
