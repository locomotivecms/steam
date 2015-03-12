module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class Page

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              super
              load_tree
            end

            private

            def path
              @path ||= File.join(site_path, 'app', 'views', 'pages')
            end

            def load_tree
              {}.tap do |hash|
                each_file do |filepath, relative_path, fullpath, locale|

                  if leaf = hash[fullpath]
                    update(leaf, filepath, fullpath, locale)
                  else
                    leaf = build(filepath, fullpath, locale)
                  end

                  hash[fullpath] = leaf
                end
              end.values
            end

            def build(filepath, fullpath, locale)
              slug        = fullpath.split('/').last
              attributes  = get_attributes(filepath, fullpath)

              {
                title:              { locale => attributes.delete(:title) || (default_locale == locale ? slug.humanize : nil) },
                slug:               { locale => attributes.delete(:slug) || slug },
                template_path:      { locale => template_path(filepath, attributes, locale) },
                redirect_url:       { locale => attributes.delete(:redirect_url) },
                editable_elements:  build_editable_elements(attributes.delete(:editable_elements), locale),
                _fullpath:          fullpath
              }.merge(attributes)
            end

            def update(leaf, filepath, fullpath, locale)
              slug        = fullpath.split('/').last
              attributes  = get_attributes(filepath, fullpath)

              leaf[:title][locale]              = attributes.delete(:title) || slug.humanize
              leaf[:slug][locale]               = attributes.delete(:slug) || slug
              leaf[:template_path][locale]      = template_path(filepath, attributes, locale)
              leaf[:redirect_url][locale]       = attributes.delete(:redirect_url)

              update_editable_elements(leaf, attributes.delete(:editable_elements), locale)

              leaf.merge!(attributes)
            end

            def get_attributes(filepath, fullpath)
              _load(filepath, true) do |attributes, template|
                # make sure index/404 are the slugs of the index/404 pages
                attributes.delete(:slug) if %w(index 404).include?(fullpath)

                # trick to use the template of the default locale (if available)
                attributes[:template_path] = false if template.blank?
              end
            end

            def each_file(&block)
              Dir.glob(File.join(path, '**', '*')).each do |filepath|
                next unless is_liquid_file?(filepath)

                relative_path = get_relative_path(filepath)

                fullpath, extension_or_locale = relative_path.split('.')[0..1]

                locale = template_extensions.include?(extension_or_locale) ? default_locale : extension_or_locale

                yield(filepath, relative_path, fullpath, locale.to_sym)
              end
            end

            def is_liquid_file?(filepath)
              filepath =~ /\.(#{template_extensions.join('|')})$/
            end

            def template_path(filepath, attributes, locale)
              if attributes.delete(:template_path) == false && locale != default_locale
                false
              else
                filepath
              end
            end

            def get_relative_path(filepath)
              filepath.gsub(path, '').gsub(/^\//, '')
            end

            def build_editable_elements(list, locale)
              return [] if list.blank?

              list.map do |name, content|
                build_editable_element(name, content, locale)
              end
            end

            def update_editable_elements(leaf, list, locale)
              return if list.blank?

              list.each do |name, content|
                if el = find_editable_element(leaf, name)
                  el[:content][locale] = content
                else
                  leaf[:editable_elements] << build_editable_element(name, content, locale)
                end
              end
            end

            def find_editable_element(leaf, name)
              leaf[:editable_elements].find do |el|
                [el[:block], el[:slug]].join('/') == name.to_s
              end
            end

            def build_editable_element(name, content, locale)
              segments    = name.to_s.split('/')
              block, slug = segments[0..-2].join('/'), segments.last
              block       = nil if block.blank?

              { block: block, slug: slug, content: { locale => content } }
            end

          end

        end
      end
    end
  end
end
