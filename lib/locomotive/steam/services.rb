Dir[File.join(File.dirname(__FILE__), 'services', '*.rb')].each { |lib| require lib }

module Locomotive
  module Steam
    module Services

      def self.instance(request, options = {})
        Registered.new(request, options)
      end

      class Registered < Struct.new(:request, :options)

        include Morphine

        register :repositories do
          Repositories.instance
        end

        register :site_finder do
          Services::SiteFinder.new(request, repositories.site, options)
        end

        register :theme_asset_url do
          Services::ThemeAssetUrl.new(repositories.theme_asset, asset_host, configuration.theme_assets_checksum)
        end

        register :asset_host do
          Services::AssetHost.new(request, current_site, configuration.asset_host)
        end

        def current_site
          repositories.current_site
        end

        def configuration
          Locomotive::Steam.configuration
        end

      end

    end
  end
end
