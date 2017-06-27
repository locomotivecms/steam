module Locomotive
  module Steam

    class AssetHostService

      attr_reader :request, :site, :host

      def initialize(request, site, host)
        @request, @site = request, site

        @host = build_host(host, request, site)
      end

      def compute(source, timestamp = nil)
        return source if source.blank?

        timestamp ||= (site.try(:template_version) || site.try(:updated_at)).to_i

        return add_timestamp_suffix(source, timestamp) if source =~ Steam::IsHTTP

        url = self.host ? build_url(host, source) : source

        add_timestamp_suffix(url, timestamp)
      end

      private

      def build_url(host, source)
        clean_source = source.sub(/\A^\//, '')
        URI.join(host, clean_source).to_s
      end

      def build_host(host, request, site)
        if site && site.try(:asset_host) && !site.asset_host.empty?
          site.asset_host =~ Steam::IsHTTP ? site.asset_host : "https://#{site.asset_host}"
        elsif host
          if host.respond_to?(:call)
            host.call(request, site)
          else
            host =~ Steam::IsHTTP ? host : "https://#{host}"
          end
        else
          nil
        end
      end

      def add_timestamp_suffix(source, timestamp)
        if timestamp.nil? || timestamp == 0 || source.include?('?')
          source
        else
          "#{source}?#{timestamp}"
        end
      end

    end

  end
end
