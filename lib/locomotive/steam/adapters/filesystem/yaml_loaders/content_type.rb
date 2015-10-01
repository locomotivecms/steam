module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class ContentType

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              super
              load_list
            end

            private

            def load_list
              [].tap do |array|
                each_file do |filepath, slug|
                  attributes = _load(filepath)
                  attributes[:entries_custom_fields] = build_fields(attributes.delete(:fields))
                  array << { _id: slug.to_s, slug: slug }.merge(attributes)
                end
              end
            end

            def build_fields(list)
              list.each_with_index.map do |attributes, index|
                build_field(attributes.keys.first, attributes.values.first, index)
              end
            end

            def build_field(name, attributes, position)
              attributes.tap do |attributes|
                attributes[:name]     = name.to_s
                attributes[:type]     = (attributes[:type] || 'string').to_s.downcase
                attributes[:position] ||= position

                if attributes[:label].blank?
                  attributes[:label] = name.to_s.humanize
                end

                if %w(belongs_to has_many many_to_many).include?(attributes[:type])
                  attributes[:localized] = false
                end

                if select_options = attributes.delete(:select_options)
                  attributes[:select_options] = build_select_options(select_options)
                end
              end
            end

            def build_select_options(options)
              if options.is_a?(Hash)
                build_select_options_from_hash(options)
              else
                build_select_options_from_array(options)
              end
            end

            def build_select_options_from_hash(options)
              [].tap do |list|
                options.each do |locale, values|
                  values.each_with_index do |name, position|
                    if (option = list.at(position)).nil?
                      list << { _id: name, name: { locale => name }, position: position }
                    else
                      option[name][locale] = name
                    end
                  end
                end
              end
            end

            def build_select_options_from_array(options)
              [].tap do |list|
                options.each_with_index do |name, position|
                  list << { _id: name, name: name, position: position }
                end
              end
            end

            def each_file(&block)
              Dir.glob(File.join(path, "*.yml")).each do |filepath|
                slug = File.basename(filepath, '.yml')
                yield(filepath, slug)
              end
            end

            def path
              File.join(site_path, 'app', 'content_types')
            end

          end

        end
      end
    end
  end
end
