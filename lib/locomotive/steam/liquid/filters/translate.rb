module Locomotive
  module Steam
    module Liquid
      module Filters

        module Translate

          def translate(input, locale = nil, scope = nil)
            @context.registers[:services].translator.translate(input, locale, scope) || input
          end

        end

        ::Liquid::Template.register_filter(Translate)

      end
    end
  end
end
