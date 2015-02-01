module Locomotive
  module Steam
    module Services

      class ImageResizer < Struct.new(:resizer, :assets_path)

        IsHTTP = /^https?:\/\//o

        def resize(source, geometry)
          return source if disabled? || geometry.blank?

          if file = fetch_file(source)
            file.thumb(geometry).url
          else
            Locomotive::Common::Logger.error "Unable to resize on the fly: #{source.inspect}"
            source
          end
        end

        def disabled?
          resizer.nil?
        end

        protected

        def fetch_file(source)
          url_or_path = get_url_or_path(source)

          if url_or_path =~ IsHTTP
            resizer.fetch_url(url_or_path)
          else
            path = url_or_path.sub(/(\?.*)$/, '')
            resizer.fetch_file(File.join(assets_path || '', 'public', path))
          end
        end

        def get_url_or_path(source)
          if source.is_a?(Hash)
            source['url']
          elsif source.respond_to?(:url)
            source.url
          else
            source
          end.strip
        end

      end

    end
  end
end
