module Spec
  module Helpers

    def reset!
      FileUtils.rm_rf(File.expand_path('../../../site', __FILE__))
    end

    def remove_logs
      FileUtils.rm_rf(File.expand_path('../../fixtures/default/log', __FILE__))
    end

    def run_server
      path = 'spec/fixtures/default'
      Locomotive::Steam::Logger.setup(path, false)
      reader = Locomotive::Mounter::Reader::FileSystem.instance
      reader.run!(path: path)

      Locomotive::Steam::Server.new(reader, disable_listen: true)
    end

  end
end