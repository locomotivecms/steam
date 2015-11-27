module Locomotive::Steam
  module Adapters
    module Memory

      class Order

        attr_reader :list

        def initialize(*spec)
          @list = []
          spec.compact.each do |criterion|
            @list += (case criterion
            when Array  then criterion
            when Hash   then criterion.to_a
            when String then criterion.split(',').collect { |s| build(s.strip) }
            else []
            end)
          end
        end

        def empty?
          @list.empty?
        end

        def apply_to(entry, locale)
          @list.collect do |(name, direction)|
            value = entry.send(name)

            if value.respond_to?(:translations) # localized
              value = value[locale]
            end

            asc?(direction) ? Asc.new(value) : Desc.new(value)
          end
        end

        def asc?(direction)
          direction.nil? || direction.to_sym == :asc
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
