module Locomotive
  module Steam

    class AssetHostService

      attr_reader :request, :site

      def initialize(request, site, default_host)
        @request, @site, @default_host = request, site, default_host
      end

      def compute(source, timestamp = nil)
        return source if source.blank?

        timestamp ||= (site.try(:template_version) || site.try(:updated_at)).to_i

        return add_timestamp_suffix(source, timestamp) if source.to_s =~ Steam::IsHTTP

        url = self.host ? build_url(host, source) : source

        add_timestamp_suffix(url, timestamp)
      end

      def host
        return @host if @host

        @host = if site.try(:asset_host).present?
          build_host_with_protocol(site.asset_host)
        elsif @default_host.respond_to?(:call)
          @default_host.call(request, site)
        elsif @default_host.present?
          build_host_with_protocol(@default_host)
        else
          nil
        end
      end

      private

      def build_url(host, source)
        clean_source = source.sub(/\A^\//, '')
        URI.join(host, clean_source).to_s
      end

      def add_timestamp_suffix(source, timestamp)
        if timestamp.nil? || timestamp == 0 || source.include?('?')
          source
        else
          "#{source}?#{timestamp}"
        end
      end

      def build_host_with_protocol(host)
        host =~ Steam::IsHTTP ? host : "https://#{host}"
      end

    end

  end
end
