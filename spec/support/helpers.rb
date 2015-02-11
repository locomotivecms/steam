require 'locomotive/common'

module Spec
  module Helpers

    def reset!
      FileUtils.rm_rf(File.expand_path('../../../site', __FILE__))
    end

    def remove_logs
      FileUtils.rm_rf(File.expand_path('../../fixtures/default/log', __FILE__))
    end

    def setup_common(logger_output = nil)
      Locomotive::Common.reset
      Locomotive::Common.configure do |config|
        config.notifier = Locomotive::Common::Logger.setup(logger_output)
      end
    end

    def run_server
      setup_common #(File.join(default_fixture_site_path, 'log/steam.log'))

      Locomotive::Common::Logger.info 'Server started...'
      Locomotive::Steam::Server.new(path: default_fixture_site_path).to_app
    end

    def default_fixture_site_path
      File.expand_path('../../fixtures/default/', __FILE__)
    end
  end
end
