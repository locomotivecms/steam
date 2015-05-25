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
              [].tap do |array|
                if (all = _load(path))
                  all.each do |key, values|
                    array << { key: key.to_s, values: HashConverter.to_string(values) }
                  end
                end
              end
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
