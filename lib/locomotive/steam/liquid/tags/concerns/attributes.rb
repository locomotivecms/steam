module Locomotive
  module Steam
    module Liquid
      module Tags
        module Concerns

          # Many of Liquid tags have attributes (like options)
          # This module makes sure we use the same reliable way to
          # extract and evaluate them.

          module Attributes

            attr_reader :attributes, :raw_attributes

            private

            def parse_attributes(markup, default = {})
              @attributes     = default || {}
              @raw_attributes = @attributes.dup

              return if markup.blank?

              markup.scan(tag_attributes_regexp) do |key, value|
                _key = key.to_sym

                @attributes[_key]     = block_given? ? yield(value) : ::Liquid::Expression.parse(value)
                @raw_attributes[_key] = @attributes[_key]
              end
            end

            def evaluate_attributes(context, lax: false)
              @attributes = @raw_attributes.transform_values do |value|
                _value = context.evaluate(value)
                lax && _value.nil? ? value&.name : _value
              end
            end

            def tag_attributes_regexp
              ::Liquid::TagAttributes
            end

          end

        end
      end
    end
  end
end