module Locomotive
  module Steam
    module Liquid
      module Tags
        module Csrf

          class Param < ::Liquid::Tag

            def render(context)
              service  = context.registers[:services].csrf_protection

              if service.enabled?
                %(<input type="hidden" name="#{service.field}" value="#{service.token}" />)
              else
                ''
              end
            end

          end

          class Meta < ::Liquid::Tag

            def render(context)
              service  = context.registers[:services].csrf_protection

              if service.enabled?
                %{
                  <meta name="csrf-param" content="#{service.field}" />
                  <meta name="csrf-token" content="#{service.token}" />
                }
              else
                ''
              end
            end

          end

        end

        ::Liquid::Template.register_tag('csrf_param', Csrf::Param)
        ::Liquid::Template.register_tag('csrf_meta', Csrf::Meta)

      end
    end
  end
end
