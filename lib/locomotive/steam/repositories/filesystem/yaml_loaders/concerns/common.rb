module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module YAMLLoaders
          module Concerns

            module Common

              def load(path, frontmatter = false)
                if File.exists?(path)
                  yaml = File.open(path).read.force_encoding('utf-8')

                  if frontmatter
                    yaml =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)(.*)/m
                    yaml = $1
                  end

                  HashConverter.to_sym(YAML.load(yaml))
                else
                  Locomotive::Common::Logger.error "No #{path} file found"
                  {}
                end
              end

              def template_extensions
                @extensions ||= %w(liquid haml)
              end

            end

          end
        end
      end
    end
  end
end
