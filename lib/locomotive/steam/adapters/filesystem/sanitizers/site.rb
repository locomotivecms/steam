module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers

        class Site

          include Adapters::Filesystem::Sanitizer

          def apply_to_entity(entity)
            entity.metafields_schema = clean_metafields_schema(entity.metafields_schema)
            entity.routes            = build_routes(entity.routes)

            apply_metafields_samples(entity)
          end

          private

          def clean_metafields_schema(schema)
            return nil unless schema

            schema.each_with_index.map do |(namespace, definitions), position|
              {
                name:     namespace.to_s,
                label:    localized_label(definitions.delete(:label), namespace.to_s),
                fields:   parse_metafields(definitions.delete(:fields)),
                position: definitions.delete(:position) || position
              }.merge(definitions)
            end.as_json
          end

          def parse_metafields(fields)
            fields.each_with_index.map do |(name, attributes), position|
              name, attributes = name.to_a[0] if name.is_a?(Hash) # ordered list of fields

              if attributes # Hash
                attributes[:label]  = { default: attributes[:label] } if attributes[:label].is_a?(String)
                attributes[:hint]   = { default: attributes[:hint] } if attributes[:hint].is_a?(String)
              end

              { name: name.to_s, position: position }.merge(attributes || {})
            end
          end

          def apply_metafields_samples(entity)
            entity.metafields_schema&.each do |namespace|
              namespace[:fields].each do |field|
                next unless field[:sample].present?

                entity.metafields ||= {}
                entity.metafields[namespace[:name]] ||= {}
                entity.metafields[namespace[:name]][field[:name]] = field[:sample]
              end
            end
          end

          def localized_label(label, default)
            case label
            when Hash   then label
            when String then { default: label }
            else { default: default}
            end
          end

          def build_routes(definitions)
            return [] if definitions.blank?

            definitions.map do |definition|
              if definition.size == 1
                # format: { '/posts/:year/:month' => 'blog' }
                {
                  'route'       => definition.keys.first,
                  'page_handle' => definition.values.first
                }
              else
                # format: { 'route' => '/posts/:year/:month', 'page_handle' => 'blog' }
                definition.stringify_keys
              end
            end
          end

        end
      end
    end
  end
end
