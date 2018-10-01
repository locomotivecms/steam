module Locomotive::Steam
  module Middlewares

    # Redirect to the same page with or without the locale in the url
    # based on the "prefix_default_locale" property of the current site.
    #
    # See the specs (spec/unit/middlewares/locale_redirection_spec.rb) for more details.
    #
    class LocaleRedirection < ThreadSafe

      include Concerns::Helpers

      def _call
        if redirect_to_root_path_with_lang
          redirect_to(path_with_locale, 302)
        elsif url = redirect_url
          redirect_to url
        end
      end

      protected

      def redirect_url
        if apply_redirection?
          if site.prefix_default_locale
            path_with_locale if locale_not_mentioned_in_path?
          else
            env['steam.path'] if default_locale? && locale_mentioned_in_path?
          end
        end
      end

      def apply_redirection?
        site.locales.size > 1 && request.get? && env['PATH_INFO'] != '/sitemap.xml'
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

      def path_with_locale
        modify_path do |segments|
          segments.insert(1, locale)
        end
      end

      def redirect_to_root_path_with_lang
        locale_not_mentioned_in_path? && path.gsub(/^\//, '') == '' && !default_locale?
      end
    end
  end

end
