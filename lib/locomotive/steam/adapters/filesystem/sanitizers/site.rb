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

            schema.map do |namespace, definitions|
              {
                name:   { default: namespace.to_s }.merge(definitions.delete(:name) || {}),
                fields: parse_metafields(definitions.delete(:fields))
              }.merge(definitions)
            end
          end

          def parse_metafields(fields)
            fields.map do |name, attributes|
              if attributes # Hash
                attributes[:hint] = { default: attributes[:hint] } if attributes[:hint].is_a?(String)

                { name: { default: name.to_s }.merge(attributes.delete(:name)) }.merge(attributes)
              else # Array
                { name: { default: name.to_s } }
              end
            end
          end

        end
      end
    end
  end
end
