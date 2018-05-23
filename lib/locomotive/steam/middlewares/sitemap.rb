module Locomotive::Steam
  module Middlewares

    class Sitemap < ThreadSafe

      include Concerns::Helpers

      def _call
        if env['PATH_INFO'] == '/sitemap.xml' && (page.nil? || page.not_found?)
          render_response(build_xml, 200, 'text/plain')
        end
      end

      private

      def build_xml
        <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>#{base_url}</loc>
    <priority>1.0</priority>
  </url>
#{build_pages_to_xml}
</urlset>
        EOF
      end

      def build_pages_to_xml
        page_repository.published.map do |page|
          next if skip_page?(page)

          build_page_xml(page)
        end.flatten.join.strip
      end

      def build_page_xml(page)
        _page = Locomotive::Steam::Decorators::I18nDecorator.new(page)

        site.locales.map do |locale|
          _page.__locale__ = locale

          next if _page.title.blank? # should be translated

          if _page.templatized?
            build_templatized_page_xml(_page, locale)
          else
            page_to_xml(_page, locale)
          end
        end
      end

      def build_templatized_page_xml(page, locale)
        content_type = repositories.content_type.find(page.content_type_id)

        return nil unless build_templatized_page_xml?(page, content_type, locale)

        repositories.content_entry.with(content_type).all.map do |entry|
          next unless entry.visible? # only visible content entry

          _entry = Locomotive::Steam::Decorators::I18nDecorator.new(entry, locale)

          next if _entry._label.blank? # should be translated

          page.content_entry = _entry

          page_to_xml(page, locale)
        end
      end

      def page_to_xml(page, locale)
        last_modification = (page.content_entry || page).updated_at.to_date

        <<-EOF
  <url>
    <loc>#{base_url}#{url_for(page, locale)}</loc>
    <lastmod>#{last_modification.to_s('%Y-%m-%d')}</lastmod>
    <priority>0.9</priority>
  </url>
        EOF
      end

      def skip_page?(page)
        page.index? ||
        page.not_found? ||
        page.layout? ||
        page.redirect? ||
        (!page.templatized? && !page.listed?)
      end

      def repositories
        services.repositories
      end

      def page_repository
        repositories.page
      end

      def url_for(page, locale = nil)
        services.url_builder.url_for(page, locale)
      end

      def build_templatized_page_xml?(page, content_type, locale)
        return true if content_type.localized? || default_locale == locale

        # does the templatized page have the same source
        # (liquid template) as in the default locale?
        # If so, no need to add a xml entry for this page
        !page.source.blank?
      end

      def base_url
        "#{request.scheme}://#{request.host_with_port}"
      end

    end

  end
end
