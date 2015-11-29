module Locomotive
  module Steam
    module Liquid
      module Tags
        module Editable
          class Text < Base

            protected

            def render_element(context, element)
              with_inline_editing(context, element) do
                content = if default_content?(element)
                  render_default_content
                else
                  element.content
                end

                format_content(content, element.format, context)
              end
            end

            def format_content(content, format, context)
              case format
              when 'markdown' then markdown_service(context).to_html(content)
              else
                content
              end
            end

            def with_inline_editing(context, element, &block)
              if editable?(context, element)
                %{<span class="locomotive-editable-text" id="#{dom_id(context)}" data-element-id="#{element._id}">#{yield}</span>}
              else
                yield
              end
            end

            def editable?(context, element)
              !!context.registers[:live_editing] && element.inline_editing
            end

            def default_content?(element)
              element.content.blank?
            end

            def default_element_attributes
              super.merge(
                content_from_default: self.render_default_content,
                format:               @element_options[:format] || 'html',
                rows:                 @element_options[:rows] || 10,
                line_break:           @element_options[:line_break].blank? ? true : @element_options[:line_break]
              )
            end

            def dom_id(context)
              block_name = context['block'].try(:name).try(:gsub, '/', '-')
              ['locomotive-editable-text', block_name, @slug].compact.join('-')
            end

            def markdown_service(context)
              context.registers[:services].markdown
            end

          end

          ::Liquid::Template.register_tag('editable_text'.freeze, Text)

          class ShortText < Text
            def initialize(tag_name, markup, options)
               Locomotive::Common::Logger.warn %(The "#{tag_name}" liquid tag is deprecated. Use "editable_text" instead.).yellow
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
