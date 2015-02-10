module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module MemoryAdapter
          class Condition

            class UnsupportedOperator < StandardError; end

            OPERATORS = %i(== eq ne neq matches gt gte lt lte size all in nin).freeze

            attr_reader :field, :operator, :value

            def initialize(operator_and_field, value, locale)
              @locale = locale.to_sym
              @operator_and_field, @value = operator_and_field, value
              @operator, @field = :==, nil

              decode_operator_and_field!
            end

            def matches?(entry)
              entry_value = entry_value(entry)

              adapt_operator!(entry_value)
              case @operator
              when :==        then entry_value == @value
              when :eq        then entry_value == @value
              when :ne        then entry_value != @value
              when :neq       then entry_value != @value
              when :matches   then @value =~ entry_value
              when :gt        then entry_value > @value
              when :gte       then entry_value >= @value
              when :lt        then entry_value < @value
              when :lte       then entry_value <= @value
              when :size      then entry_value.size == @value
              when :all       then array_contains?([*@value], entry_value)
              when :in, :nin  then value_is_in_entry_value?(entry_value)
              else
                raise UnknownConditionInScope.new("#{@operator} is unknown or not implemented.")
              end
            end

            def to_s
              "#{field} #{operator} #{@value.to_s}"
            end

            protected

            def entry_value(entry)
              case (value = entry.send(@field))
              when Hash
                value.fetch(@locale) { nil }
              else
                value
              end
            end

            def decode_operator_and_field!
              if match = @operator_and_field.match(/^(?<field>[a-z0-9_-]+)\.(?<operator>.*)$/)
                @field    = match[:field].to_sym
                @operator = match[:operator].to_sym
                check_operator!
              end

              @operator = :matches if @value.is_a?(Regexp)
            end

            def adapt_operator!(value)
              case value
              when Array
                @operator = :in if @operator == :==
              end
            end

            def value_is_in_entry_value?(value)
              _matches = if value.is_a?(Array)
                array_contains?([*value], [*@value])
              else
                [*@value].include?(value)
              end
              @operator == :in ? _matches : !_matches
            end

            private

            def check_operator!
              raise UnsupportedOperator.new unless OPERATORS.include?(@operator)
            end

            def array_contains?(source, target)
              source & target == target
            end

          end

        end
      end
    end
  end
end
