module Locomotive
  module Steam
    module Liquid
      module Filters
        module Number

          def money(input, *options)
            NumberProxyHelper.new(:currency, @context).invoke(input, options)
          end

          def percentage(input, *options)
            NumberProxyHelper.new(:percentage, @context).invoke(input, options)
          end

          class NumberProxyHelper

            include ActiveSupport::NumberHelper

            def initialize(name, context)
              @name     = name
              @context  = context
            end

            def invoke(input, options)
              _options = parse_and_interpolate_options(options)
              send :"number_to_#{@name}", input, _options
            end

            def parse_and_interpolate_options(string_or_array)
              return {} if string_or_array.empty?

              string = [*string_or_array].flatten.join(', ')
              arguments = Solid::Arguments.parse(string)

              (arguments.interpolate(@context).first || {})
            end

          end

          ::Liquid::Template.register_filter(Number)

        end

      end
    end
  end
end
