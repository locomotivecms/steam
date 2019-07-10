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
            if definition.key?('default') && definition.key?('dropzone_presets')
              definition['dropzone_presets'].each_with_index do |preset_def, i|
                if preset_def['use_default']
                  # Fallback to use setting `default` key for Standalone/Global section settings and block settings
                  definition['default']['settings'].each do |k,v|
                    if !preset_def['settings'].key?(k)
                      definition['dropzone_presets'][i]['settings'][setting['id']] = v
                    end
                  end

                  preset_def['blocks'] ||= []
                  definition['default']['blocks'] ||= []

                  definition['dropzone_presets'][i]['blocks'] = preset_def['blocks'] + definition['default']['blocks']
                end
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
