module Locomotive
  module Steam

    class Configuration

      attr_accessor :mode
      attr_accessor :theme_assets_checksum
      attr_accessor :asset_host

      attr_accessor :assets_path
      attr_accessor :image_resizer_secret

      def initialize
        self.mode                   = :production
        self.theme_assets_checksum  = false

        self.image_resizer_secret   = 'please change it'
      end
    end

  end
end
