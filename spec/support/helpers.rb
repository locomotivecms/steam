require 'locomotive/common'
require 'locomotive/models'
require 'locomotive/adapters/memory_adapter'
require_relative '../../lib/locomotive/steam/initializers'
require_relative '../../lib/locomotive/steam/loaders/yml_loader'

module Spec
  module Helpers


    def bootstrap_site_content
      Locomotive::Steam::Loader::YmlLoader.new(default_fixture_site_path, mapper).load!
    end

    def mapper
      @mapper ||= begin
        adapter = Locomotive::Adapters::MemoryAdapter
        Locomotive::Mapper.load_from_file! adapter, File.join(File.expand_path('lib/locomotive/steam/mapper.rb'))
      end
    end

    alias :bootstrap_models :mapper

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
