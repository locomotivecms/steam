module Locomotive
  module Steam
    module Liquid
      module Tags
        module Editable
          class Text < Base

          end

          ::Liquid::Template.register_tag('editable_text', Text)
        end
      end
    end
  end
end