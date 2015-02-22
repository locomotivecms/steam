module Locomotive::Steam
  module Adapters
    module Memory

      class Order

        attr_reader :list

        def initialize(*args)
          strings = args.compact

          @list = (case args.size
          when 0 then []
          when 1 then args.first.split(',').collect { |s| build(s.strip) }
          else
            args.collect { |s| build(s) }
          end)
        end

        def empty?
          @list.empty?
        end

        def apply_to(entry, locale)
          @list.collect do |(name, direction)|
            value = entry.send(name)
            asc?(direction) ? Asc.new(value) : Desc.new(value)
          end
        end

        def asc?(direction)
          direction.nil? || direction == :asc
        end

        private

        def build(string)
          pattern = string.include?('.') ? '.' : ' '
          string.downcase.split(pattern).map(&:to_sym)
        end

        class Direction
          attr_reader :obj
          def initialize(obj); @obj = obj; end
        end

        class Asc < Direction
          def <=>(other); @obj <=> other.obj; end
        end

        class Desc < Direction
          def <=>(other); other.obj <=> @obj; end
        end

      end

    end
  end
end
