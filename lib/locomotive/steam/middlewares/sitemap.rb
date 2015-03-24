module Locomotive::Steam
  module Middlewares

    class Sitemap < ThreadSafe

      include Helpers

      def _call
        if env['PATH_INFO'] == '/sitemap.xml'
          render_response(build_xml.tap { |o| puts o }, 200, 'text/plain')
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
        repositories.page.published.map do |page|
          next if page.index? || page.not_found?

          build_page_xml(page)
        end.flatten.join
      end

      def build_page_xml(page)
        _page = Locomotive::Steam::Decorators::I18nDecorator.new(page)

        site.locales.map do |locale|
          _page.__locale__ = locale

          if _page.templatized?
            build_templatized_page_xml(_page, locale)
          elsif !_page.title.blank? # should be translated
            page_to_xml(_page, locale)
          end
        end
      end

      def build_templatized_page(page, locale)
        content_type = repositories.content_type.
        # TODO
      end

      def page_to_xml(page, locale)
        <<-EOF
  <url>
    <loc>#{base_url}#{url_for(page, locale)}</loc>
    <lastmod>#{page.updated_at.to_date.to_s('%Y-%m-%d')}</lastmod>
    <priority>0.9</priority>
  </url>
        EOF
      end

      def repositories
        services.repositories
      end

      def url_for(page, locale = nil)
        services.url_builder.url_for(page, locale)
      end

      def base_url
        "#{request.scheme}://#{request.host_with_port}"
      end

    end

  # @pages.each do |page|
  #   if not page.index_or_not_found?
  #     if page.templatized?
  #       page.fetch_target_entries(_visible: true).each do |c|
  #         if c._slug.present?
  #           xml.url do
  #             xml.loc public_page_url(page, { content: c })
  #             xml.lastmod c.updated_at.to_date.to_s('%Y-%m-%d')
  #             xml.priority 0.9
  #           end
  #         end
  #       end
  #     else
  #       xml.url do
  #         xml.loc public_page_url(page)
  #         xml.lastmod page.updated_at.to_date.to_s('%Y-%m-%d')
  #         xml.priority 0.9
  #       end
  #     end
  #   end
  # end

  end
end
