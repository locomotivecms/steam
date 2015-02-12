module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class ThemeAsset < Struct.new(:site)

          def url_for(path)
            path
            # ['', 'sites', site._id.to_s, 'theme', path].join('/') # Engine
          end

          def checksums
            raise 'TODO checksums'
            # site.theme_assets.checksums # Engine
          end

        end

      end
    end
  end
end
