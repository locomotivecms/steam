module Locomotive
  module Steam
    module Liquid
      module Filters

        module Array

          def pop(array, input = 1)
            return array unless array.is_a?(::Array)
            new_ary = array.dup
            new_ary.pop(input.to_i || 1)
            new_ary
          end

          def push(array, input)
            return array unless array.is_a?(::Array)
            new_ary = array.dup
            new_ary.push(input)
            new_ary
          end

          def shift(array, input = 1)
            return array unless array.is_a?(::Array)
            new_ary = array.dup
            new_ary.shift(input.to_i || 1)
            new_ary
          end

          def unshift(array, input)
            return array unless array.is_a?(::Array)
            new_ary = array.dup
            new_ary.unshift(*input)
            new_ary
          end

        end

        ::Liquid::Template.register_filter(Array)

      end
    end
  end
end
