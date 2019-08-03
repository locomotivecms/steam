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

            json, template  = match[:json], match[:template]
            definition      = load_definition(json, entity.template_path)

            # bit of transformations to ease the designer/developer's life
            handle_aliases(definition)
            fill_presets(definition)
            set_default_values(definition)

            # update the entity
            entity.definition = definition
            entity.template   = template
          end

          def load_definition(json, template_path)
            MultiJson.load(json)
          rescue MultiJson::ParseError => e
            raise Locomotive::Steam::JsonParsingError.new(e, template_path, json)
          end

          # allow multiple ways of defining global and preset content
          def handle_aliases(definition)
            # Dropzone presets -> presets
            if presets = definition.delete('dropzone_presets')
              definition['presets'] = presets
            end

            # Global content -> default
            if default = definition.delete('global_content')
              definition['default'] = default
            end
          end

          # Utilize global defaults for dropzone preset
          # when `use_default` is defined
          def fill_presets(definition)
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
          end

          # use the default setting values if some settings
          # are not set in the default object
          def set_default_values(definition)
            content = definition['default']

            return if content.nil?

            settings = content['settings'] ||= {}

            definition['settings'].each do |setting|
              settings[setting['id']] ||= setting['default']
            end

            # no definition of blocks, no need to continue
            return if definition['blocks'].blank?

            # now, take care of the different type of blocks
            blocks = content['blocks'] ||= []

            blocks.each do |block|
              _definition = definition['blocks'].find { |d| d['type'] == block['type'] }

              next if _definition.nil?

              _definition['settings'].each do |setting|
                block['settings'] ||= {}
                block['settings'][setting['id']] ||= setting['default']
              end
            end
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
