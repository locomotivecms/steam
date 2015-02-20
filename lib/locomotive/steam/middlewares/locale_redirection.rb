module Locomotive::Steam
  module Middlewares

    # Redirect to the same page with or without the locale in the url
    # based on the "prefix_default_locale" property of the current site.
    #
    # See the specs (spec/unit/middlewares/locale_redirection_spec.rb) for more details.
    #
    class LocaleRedirection < ThreadSafe

      include Helpers

      def _call
        if url = redirect_url
          redirect_to url
        end
      end

      protected

      def redirect_url
        if apply_redirection?
          if site.prefix_default_locale
            path_with_default_locale if locale_not_mentioned_in_path?
          else
            path_without_default_locale if default_locale? && locale_mentioned_in_path?
          end
        end
      end

      def apply_redirection?
        site.locales.size > 1 && request.get?
      end

      def default_locale?
        locale.to_s == site.default_locale.to_s
      end

      def locale_mentioned_in_path?
        env['steam.locale_in_path']
      end

      def locale_not_mentioned_in_path?
        !locale_mentioned_in_path?
      end

      def path_with_default_locale
        modify_path do |segments|
          segments.insert(1, site.default_locale)
        end
      end

      def path_without_default_locale
        modify_path do |segments|
          segments.delete_at(1)
        end
      end

    end
  end

end
