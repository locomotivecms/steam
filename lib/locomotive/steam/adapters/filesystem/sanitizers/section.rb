module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers
        class Section

          include Adapters::Filesystem::Sanitizer

          def apply_to_entity(entity)
            super.tap do
              # allow multiple ways of defining global and preset content
              handle_aliases(entity.definition)

              # Utilize global defaults for dropzone preset
              # when `use_default` is defined
              fill_presets(entity.definition)

              # use the default setting values if some settings
              # are not set in the default object
              set_default_values(entity.definition)
            end
          end

          private

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

        end
      end
    end
  end
end
