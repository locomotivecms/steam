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
              @raw_attributes = {}

              return if markup.blank?

              markup.scan(tag_attributes_regexp) do |key, value|
                _key = key.to_sym

                @attributes[_key]     = block_given? ? yield(value) : ::Liquid::Expression.parse(value)
                @raw_attributes[_key] = value
              end
            end

            def evaluate_attributes(context)
              @attributes = @attributes.transform_values do |attribute|
                context.evaluate(attribute)
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
