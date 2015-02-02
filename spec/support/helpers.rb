require 'locomotive/common'
# require 'locomotive/models'
# require 'locomotive/adapters/memory_adapter'
require_relative '../../lib/locomotive/steam/initializers'

module Spec
  module Helpers

    def reset!
      FileUtils.rm_rf(File.expand_path('../../../site', __FILE__))
    end

    def remove_logs
      FileUtils.rm_rf(File.expand_path('../../fixtures/default/log', __FILE__))
    end

    def run_server
      Locomotive::Common.reset
      Locomotive::Common.configure do |config|
        path = File.join(default_fixture_site_path, 'log/locomotivecms.log')
        config.notifier = Locomotive::Common::Logger.setup(path)
      end

      bootstrap_site_content

      Locomotive::Common::Logger.info 'Server started...'
      Locomotive::Steam::Server.new(path: default_fixture_site_path)
    end

    def default_fixture_site_path
      File.expand_path('../../fixtures/default/', __FILE__)
    end
  end
end
