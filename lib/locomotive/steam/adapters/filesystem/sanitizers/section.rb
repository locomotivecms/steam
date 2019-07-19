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
              entity.definition = handle_aliases(MultiJson.load(json))
            rescue MultiJson::ParseError => e
              raise Locomotive::Steam::JsonParsingError.new(e, entity.template_path, json)
            end

            entity.template = template
          end

          def handle_aliases(definition)
            # Dropzone presets -> presets
            if presets = definition.delete('dropzone_presets')
              definition['presets'] = presets
            end

            # Global content -> default
            if default = definition.delete('global_content')
              definition['default'] = default
            end

            # Utilize global defaults for dropzone preset when `use_default` is defined
            if definition.key?('default') && definition.key?('presets')
              definition['presets'].each_with_index do |preset_definition, preset_index|
                next unless preset_definition.delete('use_default') == true

                settings = preset_definition['settings'] ||= {}

                # Fallback to use setting `default` key for Standalone/Global section settings and block settings
                definition['default']['settings'].each do |name, value|
                  settings[name] ||= value
                end

                preset_definition['blocks'] = (preset_definition['blocks'] || []) + definition['default']['blocks']
              end
            end

            definition
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
