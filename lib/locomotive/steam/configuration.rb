module Locomotive
  module Steam

    class Configuration

      attr_accessor :mode

      attr_accessor :repositories_builder_klass

      attr_accessor :theme_assets_checksum
      attr_accessor :asset_host

      attr_accessor :serve_assets
      attr_accessor :assets_path
      attr_accessor :image_resizer_secret

      attr_accessor :csrf_protection

      def initialize
        self.mode                   = :production
        self.theme_assets_checksum  = false

        self.serve_assets           = false

        self.image_resizer_secret   = 'please change it'

        self.csrf_protection        = true
      end
    end

  end
end
