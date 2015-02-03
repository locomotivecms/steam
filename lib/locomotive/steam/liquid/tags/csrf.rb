module Locomotive
  module Steam
    module Liquid
      module Tags
        module Csrf

          class Base < ::Liquid::Tag
            def render(context)
              service  = context.registers[:services].csrf_protection

              if service.enabled?
                render_csrf(service)

              else
                ''
              end
            end
          end

          class Param < Base
            def render_csrf(service)
              %(<input type="hidden" name="#{service.field}" value="#{service.token}" />)
            end
          end

          class Meta < Base
            def render_csrf(service)
              %{
                <meta name="csrf-param" content="#{service.field}" />
                <meta name="csrf-token" content="#{service.token}" />
              }
            end
          end

        end

        ::Liquid::Template.register_tag('csrf_param'.freeze, Csrf::Param)
        ::Liquid::Template.register_tag('csrf_meta'.freeze, Csrf::Meta)

      end
    end
  end
end
