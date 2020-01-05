module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class Site

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              attributes = _load(File.join(site_path, 'config', 'site.yml'))

              # NOTE: we can't use the locales and default_local methods here
              # since the loading is not done yet.
              locales, default_locale = attributes[:locales], attributes[:locales].first

              (attributes[:domains] ||= []).concat(%w(0.0.0.0 localhost))

              attributes[:picture] = File.expand_path(File.join(site_path, 'icon.png'))

              attributes[:metafields_schema] = load_metafields_schema

              attributes.merge!(load_from_env)

              # special treatment for the sections_content which may or may not be translated
              sections_content = attributes[:sections_content]
              if sections_content.present? && locales.size == 1 && sections_content[default_locale].nil?
                attributes[:sections_content] = { default_locale => sections_content }
              end

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
