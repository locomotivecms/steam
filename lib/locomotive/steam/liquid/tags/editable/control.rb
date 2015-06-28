module Locomotive
  module Steam
    module Liquid
      module Tags
        module Editable
          class Control < Base

            protected

            def default_element_attributes
              super.merge({
                content_from_default: self.render_default_content,
                options: @element_options[:options]
              })
            end

            def render_element(context, element)
              element.content
            end

            def render_default_content
              super.try(:strip)
            end

          end

          ::Liquid::Template.register_tag('editable_control'.freeze, Control)
        end
      end
    end
  end
end
