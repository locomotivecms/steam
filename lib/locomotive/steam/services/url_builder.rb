module Locomotive
  module Steam
    module Services

      class UrlBuilder < Struct.new(:site, :current_locale)

        def url_for(page, locale = nil)
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
          "/entry_submissions/#{content_type.slug}"
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
end
