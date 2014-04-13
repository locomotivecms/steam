module Locomotive
  module Steam
    module Services
      class Dragonfly

        attr_reader :path

        def initialize(path = nil)
          @path = path
        end

        def enabled?
          !!self.enabled
        end

        def resize_url(source, resize_string)
          image = (case url_or_path = get_url_or_path(source)
          when '', nil
            Locomotive::Steam::Logger.error "Unable to resize on the fly: #{source.inspect}"
            nil
          when /^http:\/\//
            app.fetch_url(url_or_path)
          else
            app.fetch_file(File.join([self.path, 'public', url_or_path].compact))
          end)

          # apply the conversion if possible
          image ? image.thumb(resize_string).url : source
        end

        def self.app
          ::Dragonfly.app
        end

        protected

        def get_url_or_path(source)
          case source
          when String   then source.strip
          when Hash     then source['url'] || source[:url]
          else
            source.try(:url)
          end
        end

      end
    end
  end
end