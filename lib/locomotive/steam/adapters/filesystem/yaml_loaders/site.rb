module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class Site

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              attributes = _load(File.join(site_path, 'config', 'site.yml'))

              (attributes[:domains] ||= []).concat(%w(0.0.0.0 localhost))

              attributes[:picture] = File.expand_path(File.join(site_path, 'icon.png'))

              attributes[:metafields_schema] = load_metafields_schema

              [attributes]
            end

            private

            def load_metafields_schema
              schema = _load(File.join(site_path, 'config', 'metafields_schema.yml'))
            end

          end

        end
      end
    end
  end
end
