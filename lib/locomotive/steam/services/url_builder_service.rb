module Locomotive
  module Steam

    class UrlBuilderService

      attr_accessor_initialize :site, :current_locale, :request

      def url_for(page, locale = nil)
        prefix(_url_for(page, locale))
      end

      def _url_for(page, locale = nil)
        [''].tap do |segments|
          locale ||= current_locale
          same_locale = locale.to_sym == site.default_locale.to_sym

          # locale
          segments << locale unless same_locale

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

      private

      def prefix(url)
        mounted_on ? "#{mounted_on}#{url}" : url
      end

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
