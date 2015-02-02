module Locomotive
  module Steam
    module Liquid
      module Filters
        module Resize

          def resize(input, resize_string)
            @context.registers[:services].image_resizer.resize(input, resize_string) || input
          end

        end

        ::Liquid::Template.register_filter(Resize)

      end
    end
  end
end
