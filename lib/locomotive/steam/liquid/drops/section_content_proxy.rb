module Locomotive
  module Steam
    module Liquid
      module Drops

        # Represent the content of a section or a block
        # This abstraction is required to handle content manipulation
        # based on field setting type (url for instance).
        class SectionContentProxy < ::Liquid::Drop

          def initialize(content, settings)
            @content, @settings = content, settings
          end

          def before_method(name)
            value = @content[name.to_s]

            if value
              if value == ''
                value
              else
                case type_of(name)
                when 'url'          then SectionUrlField.new(*url_finder.url_for(value))
                when 'image_picker' then SectionImagePickerField.new(value)
                when 'text'         then url_finder.decode_urls_for(value)
                else value
                end
              end
            end
          end

          private

          def type_of(name)
            setting_of(name).try(:[], 'type')
          end

          def setting_of(name)
            @settings.find { |setting| setting['id'] == name.to_s }
          end

          def url_finder
            @context.registers[:services].url_finder
          end

        end

        # Drop representing the valud of an image picker.
        # It holds extra attributes like:
        # the width, height, format and cropped of the image
        class SectionImagePickerField < ::Liquid::Drop

          def initialize(url_or_attributes)
            if url_or_attributes.is_a?(String) || url_or_attributes.blank?
              @attributes = { source: url_or_attributes }
            else
              @attributes = url_or_attributes.symbolize_keys || {}
            end
          end

          def source
            @attributes[:source]
          end

          def width
            @attributes[:width]
          end

          def height
            @attributes[:height]
          end

          def cropped
            @attributes[:cropped]
          end

          def to_s
            self.cropped || self.source || ''
          end

        end

        # Drop representing the value of an url attribute
        class SectionUrlField < ::Liquid::Drop

          def initialize(url, new_window = false)
            @url, @new_window = url || '#', new_window
          end

          def new_window
            @new_window
          end

          def new_window_attribute
            !!@new_window ? 'target="_blank"' : ''
          end

          def to_s
            @url
          end

        end

      end
    end
  end
end
