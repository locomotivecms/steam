module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers
        class Section

          include Adapters::Filesystem::Sanitizer

          def apply_to_entity(entity)
            super
            parse_json(entity)
          end

          private

          def parse_json(entity)
            content = File.read(entity.template_path)

            if match = content.match(JSON_FRONTMATTER_REGEXP)
              json, template = match[:json], match[:template]

              entity.definition = JSON.parse(json)
              entity.template   = template
            end
          end
        end
      end
    end
  end
end
