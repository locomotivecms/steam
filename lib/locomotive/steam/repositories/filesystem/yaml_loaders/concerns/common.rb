module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module YAMLLoaders
          module Concerns

            module Common

              def load(path, frontmatter = false)
                yaml = File.open(path).read.force_encoding('utf-8')

                if frontmatter
                  yaml =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)(.*)/m
                  yaml = $1
                end

                raw_data = YAML.load(yaml)
                HashConverter.to_sym(raw_data)
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
