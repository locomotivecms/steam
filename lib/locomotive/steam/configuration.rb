module Locomotive
  module Steam

    class Configuration

      attr_accessor :mode, :theme_assets_checksum, :asset_host

      def initialize
        self.mode                   = :production
        self.theme_assets_checksum  = false
      end
    end

  end
end
