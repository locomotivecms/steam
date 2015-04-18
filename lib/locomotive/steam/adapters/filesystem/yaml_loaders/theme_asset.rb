module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class ThemeAsset

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              super
              [].tap do |list|
                each_file do |filepath, folder|
                  list << { source: filepath, folder: folder }
                end
              end
            end

            private

            def each_file(&block)
              # Follows symlinks and makes sure subdirectories are handled
              pattern = ['**', '*', '**', '*']

              Dir.glob(File.join(path, *pattern)).each do |file|
                next if exclude?(file)

                folder = File.dirname(file.gsub(File.join(path, ''), ''))

                yield(file, folder)
              end
            end

            def exclude?(file)
              File.directory?(file) ||
              file.starts_with?(File.join(path, 'samples')) ||
              File.basename(file).starts_with?('_')
            end

            def path
              @path ||= File.join(site_path, 'public')
            end

          end
        end
      end
    end
  end
end

