module Locomotive
  module Steam

    class ImageResizerService

      attr_accessor_initialize :resizer, :asset_path

      def resize(source, geometry, convert = "")
        return get_url_or_path(source) if disabled? || geometry.blank?

        if file = fetch_file(source)
          transformed_file = file.thumb(geometry)
          transformed_file = transformed_file.convert(convert) if !convert.blank?
          transformed_file.url
        else
          Locomotive::Common::Logger.error "Unable to resize on the fly: #{source.inspect}"
          nil
        end
      end

      def disabled?
        resizer.nil? || resizer.plugins[:imagemagick].nil?
      end

      protected

      def fetch_file(source)
        return nil if source.blank?
        url_or_path = get_url_or_path(source)

        if url_or_path =~ Steam::IsHTTP
          resizer.fetch_url(url_or_path)
        elsif url_or_path
          path = url_or_path.sub(/(\?.*)$/, '')
          resizer.fetch_file(File.join(asset_path || '', path))
        end
      end

      def get_url_or_path(source)
        value = if source.is_a?(Hash)
          source['url']
        elsif source.respond_to?(:url)
          source.url
        else
          source&.to_s
        end
        value.strip if value
      end

    end

  end
end
