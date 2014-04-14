require 'common'
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
        path = File.join(File.expand_path('../../spec/fixtures/default/log/locomotivecms.log'))
        config.notifier = Locomotive::Common::Logger.setup(path)
      end

      Locomotive::Common::Logger.info 'Server started...'

      reader = Locomotive::Mounter::Reader::FileSystem.instance
      reader.run!(path: 'spec/fixtures/default')

      Locomotive::Steam::Server.new(reader)
    end

  end
end