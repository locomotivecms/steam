Dir[File.join(File.dirname(__FILE__), 'services', '*.rb')].each { |lib| require lib }

require 'morphine'

module Locomotive
  module Steam
    module Services

      def self.build_instance(request = nil, options = {})
        Instance.new(request, options)
      end

      class Instance < Struct.new(:request, :options)

        include Morphine

        register :repositories do
          Steam::Repositories.build_instance
        end

        register :site_finder do
          Steam::Services::SiteFinder.new(repositories.site, request, options)
        end

        register :page_finder do
          Steam::Services::PageFinder.new(repositories.page)
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

        def current_site
          repositories.current_site
        end

      end

    end
  end
end
