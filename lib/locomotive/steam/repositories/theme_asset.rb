module Locomotive
  module Steam
    module Repositories

      class ThemeAsset < Struct.new(:site)

        def url_for(path)
          URI.join('sites', site._id, 'theme', path).to_s
        end

        def checksums
          @site.theme_assets.checksums
        end

      end

    end
  end
end
