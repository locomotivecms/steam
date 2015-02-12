module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module YAMLLoaders

          class Site < Struct.new(:root_path, :cache)

            include YAMLLoaders::Concerns::Common

            def attributes
              cache.fetch('config/site') do
                load(File.join(root_path, 'config', 'site.yml'))
              end
            end

          end

        end
      end
    end
  end
end
