module Locomotive
  module Steam

    class UrlBuilderService

      attr_accessor_initialize :site, :current_locale, :request

      def url_for(page, locale = nil)
        prefix(_url_for(page, locale))
      end

      def _url_for(page, locale = nil)
        [''].tap do |segments|
          locale          = locale&.to_sym
          _locale         = (locale || current_locale).to_sym
          default_locale  = site.default_locale.to_sym
          same_locale     = _locale == default_locale

          fullpath = sanitized_fullpath(page, same_locale)

          # To insert the locale in the path, 2 cases:
          #
          # 1.  if the prefix_default_locale is enabled, we need to
          #     add the locale no matter if the locale is the same as the default one.
          #
          # 2.  since we also store the locale in session, calling the index page ("/")
          #     will always return the page in the locale stored in session.
          #     In order to see the index page in the default locale, we need to allow
          #     "/<default locale>" instead of just "/".
          #
          if site.prefix_default_locale || !same_locale
            segments << _locale
          elsif fullpath.blank? && locale == default_locale && current_locale != locale
            segments << locale
          end

          # we don't want a trailing slash for the home page if a locale is set
          fullpath = nil if segments.size == 2 && fullpath.blank?

          segments << fullpath
        end.compact.join('/')
      end

      def public_submission_url_for(content_type)
        prefix(_public_submission_url_for(content_type))
      end

      def _public_submission_url_for(content_type)
        "/entry_submissions/#{content_type.slug}"
      end

      def prefix(url)
        mounted_on ? "#{mounted_on}#{url}" : url
      end

      private

      def mounted_on
        return if request.nil?
        request.env['steam.mounted_on']
      end

      def sanitized_fullpath(page, same_locale)
        path = page.fullpath

        if page.templatized? && page.content_entry
          path.gsub(Locomotive::Steam::WILDCARD, page.content_entry._slug)
        elsif path == 'index'
          same_locale ? '' : nil
        else
          path
        end
      end

    end

  end
end
