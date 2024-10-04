module Locomotive
  module Steam
    module Liquid
      module Tags
        module Concerns

          # Evaluates the attributes parsed the AttributesParser
          module AttributesEvaluator
            extend ActiveSupport::Concern

            included do
              # Regexps are allowed as strings
              RegexpFragment        = /\/([^\/]+)\/([imx]+)?/o.freeze
              StrictRegexpFragment  = /\A#{RegexpFragment}\z/o.freeze

              REGEX_OPTIONS = {
                'i' => Regexp::IGNORECASE,
                'm' => Regexp::MULTILINE,
                'x' => Regexp::EXTENDED
              }.freeze
            end

            protected

            def evaluate_attributes(context)
              @attributes = context[attributes_var_name] || {} if attributes_var_name.present?

              attributes.inject({}) do |memo, (key, value)|
                # _slug instead of _permalink
                _key = key.to_s == '_permalink' ? '_slug' : key.to_s

                memo.merge({ _key => evaluate_attribute(context, value) })
              end
            end

            def evaluate_attribute(context, value)
              case value
              when Array 
                value.map { |v| evaluate_attribute(context, v) }
              when Hash
                Hash[value.map { |k, v| [k.to_s, evaluate_attribute(context, v)] }]
              when StrictRegexpFragment
                create_regexp($1, $2)
              when ::Liquid::VariableLookup
                evaluated_value = context.evaluate(value)
                evaluated_value.respond_to?(:_id) ? evaluated_value.send(:_source) : evaluate_attribute(context, evaluated_value)
              else 
                value
              end
            end

            def create_regexp(value, unparsed_options)
              options = unparsed_options.blank? ? nil : unparsed_options.split('').uniq.inject(0) do |_options, letter|
                _options |= REGEX_OPTIONS[letter]
              end
              Regexp.new(value, options)
            end
          end
        end
      end
    end
  end
end
