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
            json_formatter = /^---(?<json>(\s*\n.*?\n?))^---/mo
            file_path = entity.template_path
            file_content = File.read(file_path)
            json = file_content.match(json_formatter)
            entity.definition = JSON.parse(json[:json])
          end
        end
      end
    end
  end
end
