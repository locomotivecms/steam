module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class ThemeAsset < Struct.new(:site)

          # Engine: ['', 'sites', site._id.to_s, 'theme', path].join('/')
          def url_for(path)
            path
          end

          # Engine: site.theme_assets.checksums
          def checksums
            {}
          end

        end

      end
    end
  end
end
