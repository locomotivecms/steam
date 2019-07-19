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

          def in_groups_of(array, number, fill_with = nil)
            return array unless array.respond_to?(:all) || array.respond_to?(:each_slice)

            number        = number.to_i
            grouped_array = array.respond_to?(:all) ? array.all : array

            if fill_with != false
              # size % number gives how many extra we have;
              # subtracting from number gives how many to add;
              # modulo number ensures we don't add group of just fill.
              padding = (number - grouped_array.size % number) % number
              grouped_array = grouped_array + ::Array.new(padding, fill_with)
            end

            grouped_array.each_slice(number).to_a
          end

        end

        ::Liquid::Template.register_filter(Array)

      end

    end
  end
end
