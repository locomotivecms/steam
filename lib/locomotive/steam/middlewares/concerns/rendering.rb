module Locomotive::Steam
  module Middlewares
    module Concerns
      module Rendering

        extend ActiveSupport::Concern

        included do
          include Concerns::LiquidContext
        end

        private

        def render_page
          content = parse_and_render_liquid

          # for a better SEO score, it's better to use a CDN host including
          # the main domain name.
          content = replace_asset_host(content) if site.asset_host.present?

          render_response(content, page.not_found? ? 404 : 200, page.response_type)
        end

        def render_missing_404
          message = (if locale != default_locale
            "Your 404 page is missing in the #{locale} locale."
          else
            "Your 404 page is missing."
          end) + " Please create it."

          log "[Warning] #{message}".red

          render_response(message, 404)
        end

        def parse_and_render_liquid
          document = services.liquid_parser.parse(page)
          begin
            document.render(liquid_context)
          rescue Locomotive::Steam::ParsingRenderingError => e
            e.template_name = page.template_path if e.template_name.blank?
            raise e
          end
        end

        def replace_asset_host(content)
          content.gsub(ASSET_URL_REGEXP, "\\1#{site.asset_host}/\\3\/\\4\\5")
        end

      end
    end
  end
end
