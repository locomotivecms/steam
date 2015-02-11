module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class ThemeAsset < Struct.new(:site)

          def url_for(path)
            ['', 'sites', site._id.to_s, 'theme', path].join('/')
          end

          def checksums
            raise 'TODO checksums'
            # site.theme_assets.checksums
          end

        end

      end
    end
  end
end
