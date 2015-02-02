module Locomotive
  module Steam
    module Liquid
      module Tags
        class Javascript < ::Liquid::Block

          # TODO
          # include ActionView::Helpers::JavaScriptHelper
          # include ActionView::Helpers::TagHelper

          def render(context)
            javascript_tag super
          end
        end

        ::Liquid::Template.register_tag('javascript', Javascript)

      end
    end
  end
end
