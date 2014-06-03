require 'locomotive/common'
require 'locomotive/models'
require_relative '../../lib/locomotive/steam/initializers'
require_relative '../../lib/locomotive/steam/loaders/yml_loader'

module Spec
  module Helpers

    def bootstrap_site
      adapter = Locomotive::Adapters::MemoryAdapter
      mapper = Locomotive::Mapper.load_from_file! adapter, File.join(File.expand_path('lib/locomotive/steam/mapper.rb'))
      mapper.load!
      Locomotive::Steam::Loader::YmlLoader.new(site_path, mapper).load!
    end

    def reset!
      FileUtils.rm_rf(File.expand_path('../../../site', __FILE__))
    end

    def remove_logs
      FileUtils.rm_rf(File.expand_path('../../fixtures/default/log', __FILE__))
    end

    def run_server
      Locomotive::Common.reset
      Locomotive::Common.configure do |config|
        path = File.join(site_path, 'log/locomotivecms.log')
        config.notifier = Locomotive::Common::Logger.setup(path)
      end

      Locomotive::Common::Logger.info 'Server started...'
      Locomotive::Steam::Server.new(path: site_path)
    end

    def site_path
      File.expand_path('../../fixtures/default/', __FILE__)
    end
  end
end
