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
            match   = content.match(JSON_FRONTMATTER_REGEXP)

            raise_parsing_error(entity, content) if match.nil?

            json, template = match[:json], match[:template]

            begin
              entity.definition = MultiJson.load(json)
            rescue MultiJson::ParseError => e
              raise Locomotive::Steam::JsonParsingError.new(e, entity.template_path, json)
            end

            entity.template = template
          end

          def raise_parsing_error(entity, content)
            message = 'Your section requires a valid JSON header'
            raise Locomotive::Steam::ParsingRenderingError.new(message, entity.template_path, content, 0, nil)
          end

        end
      end
    end
  end
end
