module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Sanitizers

          class ContentType < Struct.new(:default_locale, :locales)

            def apply_to(collection)
              collection.each do |content_type|
                if list = content_type.fields
                  content_type[:fields] = build_fields(list)
                end
              end
            end

            def build_fields(list)
              list.map do |attributes|
                name, _attributes = attributes.keys.first, attributes.values.first

                _attributes[:name] = name

                if _attributes[:label].blank?
                  _attributes[:label] = name.to_s.humanize
                end

                Filesystem::Models::ContentTypeField.new(_attributes)
              end
            end

          end

        end
      end
    end
  end
end
