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
            match = content.match(JSON_FRONTMATTER_REGEXP)
            raise raise_parsing_error(entity, content) if match.nil?
            json, template = match[:json], match[:template]
            entity.definition = JSON.parse(json)
            entity.template   = template
          rescue JSON::ParserError
            raise_parsing_error(entity, content)
          end

          def raise_parsing_error(entity, content)
            raise Locomotive::Steam::ParsingRenderingError.new('Your section requires a valid JSON header', entity.template_path, content, 0, nil)
          end
        end
      end
    end
  end
end
