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

            case type_of(name)
            when 'url'  then SectionUrlField.new(*url_finder.url_for(value))
            when 'text' then url_finder.decode_urls_for(value)
            else value
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

        class SectionUrlField < ::Liquid::Drop

          def initialize(url, new_window = false)
            @url, @new_window = url || '#', new_window
          end

          def new_window
            @new_window
          end

          def to_s
            @url
          end

        end

      end
    end
  end
end
