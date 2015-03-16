module Locomotive
  module Steam

    class ThemeAssetRepository

      include Models::Repository

      # Entity mapping
      mapping :theme_assets, entity: ThemeAsset

      def url_for(path)
        "#{base_url}/#{path}"
      end

      def checksums
        query { only(:checksum, :local_path) }.all.inject({}) do |memo, asset|
          memo[asset.local_path] = asset.checksum
          memo
        end
      end

    end
  end
end
