module Locomotive
  module Steam
    module Services

      class ThemeAssetUrl < Struct.new(:repository, :asset_host, :checksum)

        def buid(path)
          # keep the query string safe
          path.gsub!(/(\?+.+)$/, '')
          query_string = $1

          # build the url of the theme asset based on the persistence layer
          _url = repository.url_for(path)

          # get a timestamp only the source url does not include a query string
          timestamp = query_string.blank? ? checksums[path] : nil

          # prefix by a asset host if given
          url = asset_host.compute(_url, timestamp)

          query_string ? "#{url}#{query_string}" : url
        end

        def checksums
          if checksum?
            @checksums ||= fetch_checksums
          else
            {}
          end
        end

        def checksum?
          !!checksum
        end

        private

        def fetch_checksums
          repository.checksums
        end

      end
    end
  end
end
