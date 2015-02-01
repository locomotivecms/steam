begin
  require 'dragonfly'

  Dragonfly.app(:steam).configure do
    plugin :imagemagick,
      convert_command:  `which convert`.strip.presence || '/usr/local/bin/convert',
      identify_command: `which identify`.strip.presence || '/usr/local/bin/identify'

    verify_urls true

    secret Locomotive::Steam.configuration.image_resizer_secret

    url_format '/images/dynamic/:job/:basename.:ext'

    fetch_file_whitelist /public/

    fetch_url_whitelist /.+/
  end

  Dragonfly.logger = Locomotive::Common::Logger.instance

rescue Exception => e
  Locomotive::Common::Logger.warn %{
[Dragonfly] !disabled!
[Dragonfly] If you want to take full benefits of all the features in the LocomotiveWagon, we recommend you to install ImageMagick and RMagick. Check out the documentation here: http://doc.locomotivecms.com/editor/installation.
}
end
