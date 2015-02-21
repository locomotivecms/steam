module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class Site

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
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
