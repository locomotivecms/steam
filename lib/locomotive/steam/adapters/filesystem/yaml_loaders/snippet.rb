module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class Snippet

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              super
              load_list
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
                template_path:  { locale => filepath }
              }
            end

            def update(element, filepath, locale)
              element[:template_path][locale] = filepath
            end

            def each_file(&block)
              Dir.glob(File.join(path, "**", "*.{#{template_extensions.join(',')}}")).each do |filepath|
                basename =  File.basename(filepath)
                subfolder = filepath.sub(path, '').sub(/^\//, '').sub(basename, '')

                slug, locale = basename.split('.')[0..1]

                if template_extensions.include?(locale)
                  locale = default_locale 
                end

                slug = slug.permalink

                if subfolder != ''
                  slug.prepend(subfolder)
                end

                yield(filepath, slug, locale.to_sym)
              end
            end

            def path
              @path ||= File.join(site_path, 'app', 'views', 'snippets')
            end

          end

        end
      end
    end
  end
end
