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
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">
#{build_pages_to_xml}
</urlset>
        XML
      end

      def build_pages_to_xml
        # we request the data based on the default locale
        page_repository.locale = site.default_locale

        page_repository.published.map do |page|
          next if skip_page?(page)

          _page = Locomotive::Steam::Decorators::I18nDecorator.new(page)

          if page.templatized?
            build_templatized_page_to_xml(_page)
          else
            build_page_to_xml(_page)
          end
        end.flatten.join.strip
      end

      def build_page_to_xml(page)
        entry = { date: page.updated_at.to_date, links: [] }

        site.locales.each_with_index do |locale, index|
          page.__locale__ = locale

          # if blank, means that the page is not translated, so skip it
          next if page.title.blank?

          if index == 0 # default locale
            entry[:loc] = url_for(page, locale)
          else
            entry[:links] << { locale: locale, href: url_for(page, locale) }
          end
        end

        entry_to_xml(entry)
      end

      def build_templatized_page_to_xml(page)
        content_type = repositories.content_type.find(page.content_type_id)

        repositories.content_entry.with(content_type).all({ _visible: true }).map do |content_entry|
          _content_entry  = Locomotive::Steam::Decorators::I18nDecorator.new(content_entry, locale)
          entry           = { date: content_entry.updated_at.to_date, links: [] }

          site.locales.each_with_index do |locale, index|
            page.__locale__           = locale
            _content_entry.__locale__ = locale

            # if blank, means that the page or the content entry is not translated, so skip it
            next if _content_entry._label.blank? || page.title.blank?

            page.content_entry = _content_entry

            if index == 0 # default locale
              entry[:loc] = url_for(page, locale)
            else
              entry[:links] << { locale: locale, href: url_for(page, locale) }
            end
          end

          entry_to_xml(entry)
        end.flatten.join.strip
      end

      def entry_to_xml(entry)
        <<-XML
  <url>
    <loc>#{base_url}#{entry[:loc]}</loc>
    <lastmod>#{entry[:date].to_s('%Y-%m-%d')}</lastmod>
    #{entry_links_to_xml(entry[:links])}
  </url>
        XML
      end

      def entry_links_to_xml(links)
        links.map do |link|
          <<-XML
     <xhtml:link rel="alternate" hreflang="#{link[:locale]}" href="#{base_url}#{link[:href]}" />
          XML
        end.flatten.join.strip
      end

      def skip_page?(page)
        page.not_found? ||
        page.layout? ||
        page.redirect? ||
        (!page.templatized? && !page.index? && !page.listed?)
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

      def base_url
        "#{request.scheme}://#{request.host_with_port}"
      end

    end

  end
end
