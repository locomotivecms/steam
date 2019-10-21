module Locomotive
  module Steam
    module Liquid
      module Tags
        module Editable
          class Model < Base

            def render_to_output_buffer(context, output)
              default_render_to_output_buffer(context, output)
              output
            end

            def render_default_content
              nil
            end

          end

          ::Liquid::Template.register_tag('editable_model'.freeze, Model)
        end
      end
    end
  end
end
