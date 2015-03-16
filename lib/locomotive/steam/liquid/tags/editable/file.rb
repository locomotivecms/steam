module Locomotive
  module Steam
    module Liquid
      module Tags
        module Editable
          class File < Base

            protected

            def default_element_attributes
              super.merge({
                default_source_url: render_default_content.strip
              })
            end

            def render_element(context, element)
              default_timestamp = context.registers[:page].updated_at.to_i

              url, timestamp = (if element.source
                [source_url(element), default_timestamp]
              else
                if element.default_source_url.present?
                  [element.default_source_url, default_timestamp]
                else
                  [render_default_content, nil]
                end
              end)

              context.registers[:services].asset_host.compute(url, timestamp)
            end

            def source_url(element)
              if element.source =~ /^https?/
                element.source
              else
                "#{element.base_url}/#{element.source}"
              end
            end

          end

          ::Liquid::Template.register_tag('editable_file'.freeze, File)
        end
      end
    end
  end
end
