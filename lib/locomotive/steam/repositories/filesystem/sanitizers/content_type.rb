module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Sanitizers

          class ContentType < Struct.new(:default_locale, :locales)

            def apply_to(collection)
              collection.each do |content_type|
                if list = content_type.attributes[:fields]
                  content_type[:slug] = content_type[:slug].to_s
                  content_type.fields = build_fields(list)
                end
                build_fields_by_name_shortcut(content_type)
              end
            end

            def build_fields(list)
              list.map do |attributes|
                name, _attributes = attributes.keys.first, attributes.values.first

                _attributes[:name] = name.to_sym

                if _attributes[:label].blank?
                  _attributes[:label] = name.to_s.humanize
                end

                _attributes[:type] = _attributes[:type].try(:to_sym)

                Filesystem::Models::ContentTypeField.new(_attributes)
              end
            end

            def build_fields_by_name_shortcut(content_type)
              content_type.fields_by_name = {}

              (content_type.fields || []).each do |field|
                content_type.fields_by_name[field.name] = field
              end
            end

          end

        end
      end
    end
  end
end
