module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers

        class Site

          include Adapters::Filesystem::Sanitizer

          def apply_to_entity(entity)
            entity.metafields_schema = clean_metafields_schema(entity.metafields_schema)
          end

          private

          def clean_metafields_schema(schema)
            return nil unless schema

            schema.each_with_index.map do |(namespace, definitions), position|
              {
                name:     namespace.to_s,
                label:    { default: namespace.to_s }.merge(definitions.delete(:label) || {}),
                fields:   parse_metafields(definitions.delete(:fields)),
                position: definitions.delete(:position) || position
              }.merge(definitions)
            end.as_json
          end

          def parse_metafields(fields)
            fields.each_with_index.map do |(name, attributes), position|
              if attributes # Hash
                attributes[:label]  = { default: attributes[:label] } if attributes[:label].is_a?(String)
                attributes[:hint]   = { default: attributes[:hint] } if attributes[:hint].is_a?(String)
              end
              { name: name.to_s, position: position }.merge(attributes || {})
            end
          end

        end
      end
    end
  end
end
