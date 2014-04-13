module Locomotive
  module Steam
    module Liquid
      module Filters
        module Resize

          def resize(input, resize_string)
            dragonfly = @context.registers[:services][:dragonfly]
            dragonfly.resize_url(input, resize_string)
          end

        end

        ::Liquid::Template.register_filter(Resize)

      end
    end
  end
end