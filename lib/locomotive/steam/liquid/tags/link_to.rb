module Locomotive
  module Steam
    module Liquid
      module Tags
        class LinkTo < Hybrid

          include PathHelper

          def render(context)
            render_path(context) do |page, path|
              label = label_from_page(page)

              if render_as_block?
                context.stack do
                  context.scopes.last['target'] = page
                  label = super.html_safe
                end
              end

              %{<a href="#{path}">#{label}</a>}
            end
          end

          def wrong_syntax!
            raise SyntaxError.new("Syntax Error in 'link_to' - Valid syntax: link_to page_handle, locale es (locale is optional)")
          end

          protected

          def label_from_page(page)
            if page.templatized?
              page.send(:_source).content_entry._label
            else
              page.title
            end
          end

        end

        ::Liquid::Template.register_tag('link_to', LinkTo)
      end
    end
  end
end
