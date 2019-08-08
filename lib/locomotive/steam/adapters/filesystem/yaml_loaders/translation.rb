module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class Translation

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              super
              load_array
            end

            private

            def load_array
              all = env == :local ? _load(path) : _load_from_env

              [].tap do |array|
                (all || {}).each do |key, values|
                  array << { key: key.to_s, values: HashConverter.to_string(values) }
                end
              end
            end

            def _load_from_env
              safe_json_file_load(File.join(site_path, 'data', env.to_s, 'translations.json'))
            end

            def path
              File.join(site_path, 'config', 'translations.yml')
            end

          end

        end
      end
    end
  end
end
