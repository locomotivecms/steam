module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module MemoryAdapter

          class YAMLLoader < Struct.new(:root_path)

            attr_accessor :default_locale

            TEMPLATE_EXTENSIONS = %w(liquid haml)

            @@cache = {}

            def self.instance(path = nil)
              @@instance ||= self.new(path)
            end

            def simple(path)
              @@cache[path] || load(File.join(root_path, path))
            end

            def tree(path)
              @@cache[path] || load_tree(File.join(root_path, path)).values
            end

            private

            def load(path, frontmatter = false)
              yaml = File.open(path).read.force_encoding('utf-8')

              if frontmatter
                yaml =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)(.*)/m
                yaml = $1
              end

              raw_data = YAML.load(yaml)
              HashConverter.to_sym(raw_data)
            end

            def load_tree(path)
              {}.tap do |hash|
                Dir.glob(File.join(path, '**', '*')).each do |filepath|
                  next unless filepath =~ /\.(#{TEMPLATE_EXTENSIONS.join('|')})$/

                  relative_path = filepath.gsub(path, '').gsub(/^\//, '')

                  fullpath, locale = relative_path.split('.')[0..1]
                  locale = default_locale if TEMPLATE_EXTENSIONS.include?(locale)

                  if leaf = hash[fullpath]
                    update_leaf(leaf, filepath, fullpath, locale.to_sym)
                  else
                    leaf = get_new_leaf(filepath, fullpath, locale.to_sym)
                  end

                  hash[fullpath] = leaf
                end
              end
            end

            def get_new_leaf(filepath, fullpath, locale)
              slug = fullpath.split('/').last
              attributes = load(filepath, true)

              {
                title:              { locale => attributes.delete(:title) || (default_locale == locale ? slug.humanize : nil) },
                slug:               { locale => attributes.delete(:slug) || slug },
                editable_elements:  { locale => attributes.delete(:editable_elements) },
                template_path:      { locale => filepath },
                _fullpath:          fullpath
              }.merge(attributes)
            end

            def update_leaf(leaf, filepath, fullpath, locale)
              slug = fullpath.split('/').last
              attributes = load(filepath, true)

              leaf[:title][locale] = attributes.delete(:title) || slug.humanize
              leaf[:slug][locale] = attributes.delete(:slug) || slug
              leaf[:editable_elements][locale] = attributes.delete(:editable_elements)
              leaf[:template_path][locale] = filepath

              leaf.merge!(attributes)
            end

          end

        end
      end
    end
  end
end
