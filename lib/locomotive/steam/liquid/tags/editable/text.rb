module Locomotive
  module Steam
    module Liquid
      module Tags
        module Editable
          class Text < Base

            protected

            def render_element(context, element)
              with_inline_editing(context, element) do
                if element.default_content?
                  render_default_content
                else
                  element.content
                end
              end
            end

            def with_inline_editing(context, element, &block)
              if editable?(context, element)
                %{<span class="locomotive-editable-text" data-element-id="#{element.id}">#{yield}</span>}
              else
                yield
              end
            end

            def editable?(context, element)
              !!context['inline_editing'] && element.inline_editing?
            end

            def default_element_attributes
              super.merge(
                content_from_default: self.render_default_content,
                format:               @options[:format] || 'html',
                rows:                 @options[:rows] || 10,
                line_break:           @options[:line_break].blank? ? true : @options[:line_break]
              )
            end

          end

          ::Liquid::Template.register_tag('editable_text'.freeze, Text)

          class ShortText < Text
            def initialize(tag_name, markup, options)
               Locomotive::Common::Logger.warn %(The "#{tag_name}" liquid tag is deprecated. Use "editable_text" instead.)
              super
            end
            def default_element_attributes
              super.merge(format: 'raw', rows: 2, line_break: false)
            end
          end
          ::Liquid::Template.register_tag('editable_short_text'.freeze, ShortText)

          class LongText < ShortText
            def default_element_attributes
              super.merge(format: 'html', rows: 15, line_break: true)
            end
          end
          ::Liquid::Template.register_tag('editable_long_text'.freeze, LongText)

        end
      end
    end
  end
end
