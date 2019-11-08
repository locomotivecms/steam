module Locomotive
  module Steam
    module Liquid
      module Tags

        class PageNotFound < ::Liquid::Tag

          def render(context)
            raise Locomotive::Steam::PageNotFoundException.new
          end

        end

        ::Liquid::Template.register_tag('render_page_not_found'.freeze, PageNotFound)

      end
    end
  end
end
