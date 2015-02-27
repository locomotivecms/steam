module Locomotive
  module Steam

    class ThemeAssetRepository

      include Models::Repository

      mapping :theme_assets, entity: ThemeAsset

      # Engine: ['', 'sites', site._id.to_s, 'theme', path].join('/')
      # Wagon: '/' + path
      def url_for(path)
        [adapter.theme_assets_base_url(scope), path].join('/')
      end

      # Engine: site.theme_assets.checksums
      # Wagon: {}
      def checksums
        query { only(:checksum, :local_path) }.all.inject({}) do |memo, asset|
          memo[asset.local_path] = asset.checksum
          memo
        end
      end

    end
  end
end
