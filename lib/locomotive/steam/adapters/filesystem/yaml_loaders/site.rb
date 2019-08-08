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

              attributes.merge!(load_from_env)

              [attributes]
            end

            private

            def load_from_env
              return {} if env == :local

              safe_json_file_load(File.join(site_path, 'data', env.to_s, 'site.json')).symbolize_keys
            end

            def load_metafields_schema
              _load(File.join(site_path, 'config', 'metafields_schema.yml'))
            end

          end

        end
      end
    end
  end
end
