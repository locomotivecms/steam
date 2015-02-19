require 'morphine'

require_relative_all %w(concerns .), 'services'

module Locomotive
  module Steam
    module Services

      def self.build_instance(request = nil)
        Instance.new(request).tap do |service|
          if Locomotive::Steam.configuration.services_hook
            Locomotive::Steam.configuration.services_hook.call(service)
          end
        end
      end

      class Instance < Struct.new(:request)

        include Morphine

        register :repositories do
          require_relative 'repositories/filesystem.rb'
          Steam::Repositories::Filesystem.build_instance(nil, nil, configuration.site_path)
        end

        register :site_finder do
          Steam::Services::SiteFinder.new(repositories.site, request)
        end

        register :page_finder do
          Steam::Services::PageFinder.new(repositories.page)
        end

        register :parent_finder do
          Steam::Services::ParentFinder.new(repositories.page)
        end

        register :snippet_finder do
          Steam::Services::SnippetFinder.new(repositories.snippet)
        end

        register :entry_submission do
          Steam::Services::EntrySubmission.new(repositories.content_type, repositories.content_entry, current_locale)
        end

        register :liquid_parser do
          Steam::Services::LiquidParser.new(parent_finder, snippet_finder)
        end

        register :url_builder do
          Steam::Services::UrlBuilder.new(current_site, current_locale)
        end

        register :theme_asset_url do
          Steam::Services::ThemeAssetUrl.new(repositories.theme_asset, asset_host, configuration.theme_assets_checksum)
        end

        register :asset_host do
          Steam::Services::AssetHost.new(request, current_site, configuration.asset_host)
        end

        register :image_resizer do
          Steam::Services::ImageResizer.new(::Dragonfly.app(:steam), configuration.assets_path)
        end

        register :translator do
          Steam::Services::Translator.new(repositories.translation, current_locale)
        end

        register :external_api do
          Steam::Services::ExternalAPI.new
        end

        register :csrf_protection do
          Steam::Services::CsrfProtection.new(configuration.csrf_protection, Rack::Csrf.field, Rack::Csrf.token(request.env))
        end

        register :cache do
          Steam::Services::NoCache.new
        end

        register :markdown do
          Steam::Services::Markdown.new
        end

        register :textile do
          Steam::Services::Textile.new
        end

        register :configuration do
          Locomotive::Steam.configuration
        end

        register :current_locale do
          I18n.locale
        end

        def current_locale
          @current_locale || I18n.locale
        end

        def current_locale=(locale)
          # Note: "repositories" has already been initialized when called here.
          @current_locale = repositories.current_locale = locale
        end

        def current_site
          repositories.current_site
        end

      end

    end
  end
end
