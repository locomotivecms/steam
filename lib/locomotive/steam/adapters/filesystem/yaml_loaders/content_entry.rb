module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class ContentEntry

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              super
              load_list
            end

            private

            def load_list
              [].tap do |list|
                each(content_type_slug) do |label, attributes, position|
                  _attributes = { _position: position, _label: label.to_s }.merge(attributes)

                  modify_for_selects(_attributes)
                  modify_for_associations(_attributes)
                  modify_for_files(_attributes)

                  list << _attributes
                end
              end
            end

            def modify_for_selects(attributes)
              content_type.select_fields.each do |field|
                if (option = attributes.delete(field.name.to_sym)).is_a?(Hash)
                  attributes[:"#{field.name}_id"] = option.inject({}) do |memo, (locale, name)|
                    field.select_options.scope.locale = locale
                    memo[locale] = field.select_options.by_name(name).try(:_id)
                    memo
                  end
                else
                  attributes[:"#{field.name}_id"] = option
                end
              end
            end

            def modify_for_files(attributes)
              content_type.file_fields.each do |field|
                attributes[:"#{field.name}_size"] ||= {}
                value = attributes[:"#{field.name}_size"]

                if (path = attributes[field.name.to_sym]).is_a?(Hash)
                  path.each { |locale, path| value[locale.to_s] = file_size(path) }
                else
                  value['default'] = file_size(path)
                end
              end
            end

            def file_size(path)
              return nil if path.blank?

              _path = File.join(site_path, 'public', path)

              File.exists?(_path) ? File.size(_path) : nil
            end

            def modify_for_associations(attributes)
              content_type.association_fields.each do |field|
                case field.type
                when :belongs_to
                  modify_belongs_to_association(field, attributes)
                when :many_to_many
                  modify_many_to_many_association(field, attributes)
                end
              end
            end

            def modify_belongs_to_association(field, attributes)
              # <name>_id
              attributes[:"#{field.name}_id"] = attributes.delete(field.name.to_sym)

              # _position_in_<name>
              attributes[:"position_in_#{field.name}"] = attributes[:_position]
            end

            def modify_many_to_many_association(field, attributes)
              attributes[:"#{field.name.to_s.singularize}_ids"] = attributes.delete(field.name.to_sym)
            end

            def each(slug, &block)
              position = 0
              _load(File.join(path, "#{slug}.yml")).each do |element|
                label, attributes = if element.respond_to?(:keys)
                  [element.keys.first, element.values.first]
                else
                  [element, {}]
                end
                yield(label, attributes, position)
                position += 1
              end
            end

            def path
              File.join(site_path, 'data')
            end

            def content_type
              @scope.context[:content_type]
            end

            def content_type_slug
              content_type.slug
            end

          end

        end
      end
    end
  end
end
