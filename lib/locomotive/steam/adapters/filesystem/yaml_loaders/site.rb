module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class Site < Struct.new(:site_path, :cache)

            include Adapters::Filesystem::YAMLLoader

            def load
              fetch('config/site') do
                [_load(File.join(site_path, 'config', 'site.yml'))]
              end
            end

          end

        end
      end
    end
  end
end
