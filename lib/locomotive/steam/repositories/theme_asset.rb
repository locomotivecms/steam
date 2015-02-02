module Locomotive
  module Steam
    module Repositories

      class ThemeAsset < Struct.new(:site)

        def url_for(path)
          ['', 'sites', site._id.to_s, 'theme', path].join('/')
        end

        def checksums
          site.theme_assets.checksums
        end

      end

    end
  end
end
