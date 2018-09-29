module Locomotive
  module Steam

    class UrlBuilderService

      attr_accessor_initialize :site, :current_locale, :mounted_on

      def url_for(page, locale = nil)
        prefix(_url_for(page, locale))
      end

      def _url_for(page, locale = nil)
        [''].tap do |segments|
          locale ||= current_locale
          same_locale = locale.to_sym == site.default_locale.to_sym

          # if the prefix_default_locale is enabled, we need to
          # add the locale no matter if the locale is the same as the default one
          if site.prefix_default_locale || !same_locale
            segments << locale
          end

          # fullpath
          segments << sanitized_fullpath(page, same_locale)
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
