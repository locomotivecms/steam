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
                  default = { _position: position, _label: label.to_s }
                  list << default.merge(attributes)
                end
              end
            end

            def each(slug, &block)
              position = 0
              _load(File.join(path, "#{slug}.yml")).each do |element|
                label, attributes = element.keys.first, element.values.first
                yield(label, attributes, position)
                position += 1
              end
            end

            def path
              File.join(site_path, 'data')
            end

            def content_type_slug
              @scope.context[:content_type].slug
            end

          end

        end
      end
    end
  end
end
