module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders
          class Section

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              super
              load_list
            end

            private

            def load_list
              Dir.glob(File.join(path, "*.{#{template_extensions.join(',')}}")).map do |filepath|
                load_file(filepath)
              end
            end

            def load_file(filepath)
              slug        = File.basename(filepath).split('.').first
              attributes  = build(filepath, slug.permalink)

              _load(filepath, true, true) do |definition, template|
                attributes[:definition] = definition
                attributes[:template]   = template
              end

              attributes
            end

            def build(filepath, slug)
              {
                name:           slug.humanize,
                slug:           slug,
                template_path:  filepath
              }
            end

            def path
              @path ||= File.join(site_path, 'app', 'views', 'sections')
            end

          end
        end
      end
    end
  end
end
