require 'morphine'

require_relative_all %w(concerns .), 'services'

module Locomotive
  module Steam

    module Services

      def self.build_instance(request = nil)
        Instance.new(request).tap do |instance|
          if Locomotive::Steam.configuration.services_hook
            Locomotive::Steam.configuration.services_hook.call(instance)
          end
        end
      end

      class Instance < Struct.new(:request)

        include Morphine

        register :current_site do
          repositories.current_site = site_finder.find
        end

        register :repositories do
          Steam::Repositories.new(nil, nil, configuration)
        end

        register :site_finder do
          Steam::SiteFinderService.new(repositories.site, request)
        end

        register :page_finder do
          Steam::PageFinderService.new(repositories.page)
        end

        register :parent_finder do
          Steam::ParentFinderService.new(repositories.page)
        end

        register :editable_element do
          Steam::EditableElementService.new(repositories.page, locale)
        end

        register :snippet_finder do
          Steam::SnippetFinderService.new(repositories.snippet)
        end

        register :entry_submission do
          Steam::EntrySubmissionService.new(repositories.content_type, repositories.content_entry, locale)
        end

        register :liquid_parser do
          Steam::LiquidParserService.new(parent_finder, snippet_finder)
        end

        register :url_builder do
          Steam::UrlBuilderService.new(current_site, locale, request)
        end

        register :theme_asset_url do
          Steam::ThemeAssetUrlService.new(repositories.theme_asset, asset_host, configuration.theme_assets_checksum)
        end

        register :asset_host do
          Steam::AssetHostService.new(request, current_site, configuration.asset_host)
        end

        register :image_resizer do
          Steam::ImageResizerService.new(::Dragonfly.app(:steam), configuration.asset_path)
        end

        register :translator do
          Steam::TranslatorService.new(repositories.translation, locale)
        end

        register :external_api do
          Steam::ExternalAPIService.new
        end

        register :csrf_protection do
          Steam::CsrfProtectionService.new(configuration.csrf_protection, Rack::Csrf.field, Rack::Csrf.token(request.env))
        end

        register :markdown do
          Steam::MarkdownService.new
        end

        register :textile do
          Steam::TextileService.new
        end

        register :cache do
          Steam::NoCacheService.new
        end

        register :configuration do
          Locomotive::Steam.configuration
        end

        register :locale do
          I18n.locale
        end

        def locale
          @locale || I18n.locale
        end

        def locale=(locale)
          # Note: "repositories" has already been initialized when called here.
          @locale = repositories.locale = locale
        end

        def set_site(site)
          self.current_site = repositories.current_site = site
        end

      end

    end

  end
end
