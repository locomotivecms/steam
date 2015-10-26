module Locomotive
  module Steam
    module Initializers

      class Dragonfly

        def run
          require 'dragonfly'

          # need to be called outside of the configure method
          imagemagick_commands = find_imagemagick_commands

          ::Dragonfly.app(:steam).configure do
            if imagemagick_commands
              plugin :imagemagick, imagemagick_commands
            end

            verify_urls true

            secret Locomotive::Steam.configuration.image_resizer_secret

            url_format '/steam/dynamic/:job/:sha/:basename.:ext'

            fetch_file_whitelist /public/

            fetch_url_whitelist /.+/
          end

          if ::Dragonfly.logger.nil?
            ::Dragonfly.logger = Locomotive::Common::Logger.instance
          end
        end

        def find_imagemagick_commands
          convert   = `which convert`.strip.presence || '/usr/local/bin/convert'
          identify  = `which identify`.strip.presence || '/usr/local/bin/identify'

          if File.exists?(convert)
            { convert_command: convert, identify_command: identify }
          else
            missing_image_magick
            nil
          end
        end

        def missing_image_magick
          Locomotive::Common::Logger.warn <<-EOF
[Dragonfly] !disabled!
[Dragonfly] If you want to take full benefits of all the features in Locomotive Steam, we recommend you to install ImageMagick. Check out the documentation here: http://doc.locomotivecms.com.
EOF
        end

      end
    end
  end
end

Locomotive::Steam::Initializers::Dragonfly.new.run
