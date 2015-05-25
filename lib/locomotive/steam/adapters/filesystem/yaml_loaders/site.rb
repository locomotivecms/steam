module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class Site

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              attributes = _load(File.join(site_path, 'config', 'site.yml'))

              (attributes[:domains] ||= []) << 'localhost'

              attributes[:picture] = File.expand_path(File.join(site_path, 'icon.png'))

              [attributes]
            end

          end

        end
      end
    end
  end
end
