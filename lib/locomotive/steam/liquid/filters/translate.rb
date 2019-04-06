module Locomotive
  module Steam
    module Liquid
      module Filters

        module Translate

          def translate(input, options = nil, legacy_scope = nil)
            options ||= {}

            unless options.respond_to?(:values) # String
              options = { 'locale' => options, 'scope' => legacy_scope }
            end

            @context.registers[:services].translator.translate(input, options) || input
          end

          alias t translate

        end

        ::Liquid::Template.register_filter(Translate)

      end
    end
  end
end
