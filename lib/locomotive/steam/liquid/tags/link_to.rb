module Locomotive
  module Steam
    module Liquid
      module Tags
        class LinkTo < Hybrid

          include Concerns::SimpleAttributesParser
          include Concerns::I18nPage
          include Concerns::Path

          def render(context)
            render_path(context) do |page, path|
              label = label_from_page(page)

              if render_as_block?
                context.stack do
                  context.scopes.last['target'] = page
                  label = super.html_safe
                end
              end

              tag_href  = %(href="#{path}")
              tag_class = %( class="#{css}") if css.present?

              %{<a #{tag_href}#{tag_class}>#{label}</a>}
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

          def css
            attributes[:class]
          end

        end

        ::Liquid::Template.register_tag('link_to', LinkTo)
      end
    end
  end
end
