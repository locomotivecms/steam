require_relative 'initializers/sprockets.rb'
require_relative 'initializers/i18n.rb'
require_relative 'initializers/dragonfly.rb'

Locomotive::Common.configure do |config|
  config.notifier = Locomotive::Common::Logger.setup
end
