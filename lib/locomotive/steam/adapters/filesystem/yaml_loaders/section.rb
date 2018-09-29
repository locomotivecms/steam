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
                slug = File.basename(filepath).split('.').first
                build(filepath, slug.permalink)
              end
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
