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
        if apply_redirection?
          redirect_to path_with_default_locale
        end
      end

      protected

      def apply_redirection?
        site.locales.size > 1 &&
        site.prefix_default_locale &&
        request.get? &&
        env['PATH_INFO'] != '/sitemap.xml' &&
        locale_not_mentioned_in_path?
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

    end
  end

end
