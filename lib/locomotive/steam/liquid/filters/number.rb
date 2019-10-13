module Locomotive
  module Steam
    module Liquid
      module Filters
        module Number

          def money(input, options = nil)
            NumberProxyHelper.new(:currency, @context).invoke(input, options)
          end

          def percentage(input, options = nil)
            NumberProxyHelper.new(:percentage, @context).invoke(input, options)
          end

          def human_size(input, options = nil)
            NumberProxyHelper.new(:human_size, @context).invoke(input, options)
          end

          def mod(input, modulus)
            input.to_i % modulus.to_i
          end

          class NumberProxyHelper

            include ActiveSupport::NumberHelper

            def initialize(name, context)
              @name     = name
              @context  = context
            end

            def invoke(input, options)
              send :"number_to_#{@name}", input, interpolate_options(options)
            end

            def interpolate_options(options)
              (options || {}).transform_values do |option|
                if option.is_a?(String)
                  _option = ::Liquid::Expression.parse(option)
                  @context.evaluate(_option) || option
                else
                  option
                end
              end
            end

          end

          ::Liquid::Template.register_filter(Number)

        end

      end
    end
  end
end
