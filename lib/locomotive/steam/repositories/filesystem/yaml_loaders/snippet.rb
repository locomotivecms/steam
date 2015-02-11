module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module YAMLLoaders

          class Snippet < Struct.new(:root_path, :default_locale, :cache)

            include YAMLLoaders::Concerns::Common

            def list_of_attributes
              cache.fetch('app/views/pages') { load_list }
            end

            private

            def load_list
              {}.tap do |hash|
                each_file do |filepath, slug, locale|
                  _locale = locale || default_locale

                  if element = hash[slug]
                    update(element, filepath, _locale)
                  else
                    element = build(filepath, slug, _locale)
                  end

                  hash[slug] = element
                end
              end.values
            end

            def build(filepath, slug, locale)
              {
                name:           slug.humanize,
                slug:           slug,
                template_path:  { _locale => filepath }
              }
            end

            def update(element, filepath, slug, locale)
              element[:template_path][_locale] = filepath
            end

            def each_file(&block)
              Dir.glob(File.join(path, "*.{#{template_extensions.join(',')}}")).each do |filepath|

                slug, locale = File.basename(filepath).split('.')[0..1]
                locale = default_locale if template_extensions.include?(locale)

                yield(filepath, slug, locale.to_sym)
              end
            end

            def path
              File.join(root_path, 'app', 'views', 'snippets')
            end

          end

        end
      end
    end
  end
end
