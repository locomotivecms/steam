module Locomotive
  module Steam
    module Liquid
      module Tags
        module Editable
          class Model < Base

            def render(context)
              default_render(context)
            end

          end

          ::Liquid::Template.register_tag('editable_model'.freeze, Model)
        end
      end
    end
  end
end
