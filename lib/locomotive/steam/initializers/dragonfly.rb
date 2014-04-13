require 'dragonfly'

# Configure
Dragonfly.app(:steam).configure do
  plugin :imagemagick,
    convert_command:  `which convert`.strip.presence || '/usr/local/bin/convert',
    identify_command: `which identify`.strip.presence || '/usr/local/bin/identify'

  protect_from_dos_attacks true

  url_format '/images/dynamic/:job/:basename.:ext'

  fetch_file_whitelist /public/

  fetch_url_whitelist /.+/
end

Dragonfly.logger = Locomotive::Steam::Logger.instance