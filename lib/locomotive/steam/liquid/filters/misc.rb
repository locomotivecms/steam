module Locomotive
  module Steam
    module Liquid
      module Filters
        module Misc

          # was called modulo at first
          def str_modulo(word, index, modulo)
            (index.to_i + 1) % modulo == 0 ? word : ''
          end

          # Get the nth element of the passed in array
          def index(array, position)
            array.at(position) if array.respond_to?(:at)
          end

          def default(input, value)
            input.blank? ? value : input
          end

          def random(input)
            rand(input.to_i)
          end

          # map/collect on a given property (support to_f, to_i)
          def map(input, property)
            ::Liquid::StandardFilters::InputIterator.new(input).map do |e|
              e = e.call if e.is_a?(Proc)

              if property == "to_liquid".freeze
                e
              elsif property == 'to_f'.freeze
                e.to_f
              elsif property == 'to_i'.freeze
                e.to_i
              elsif e.respond_to?(:[])
                e[property]
              end
            end

          end

          def hexdigest(input, key, digest = nil)
            OpenSSL::HMAC.hexdigest(digest || 'sha1', key, input)
          end

        end

        ::Liquid::Template.register_filter(Misc)

      end
    end
  end
end
