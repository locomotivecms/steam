module Locomotive
  module Steam
    module Liquid
      module Tags

        # Filter a collection
        #
        # Usage:
        #
        # {% with_scope main_developer: 'John Doe', providers.in: ['acme'], started_at.le: today, active: true %}
        #   {% for project in contents.projects %}
        #     {{ project.name }}
        #   {% endfor %}
        # {% endwith_scope %}
        #        
        class WithScope < ::Liquid::Block

          include Concerns::AttributesParser

          # Regexps are allowed as strings
          RegexpFragment        = /\/([^\/]+)\/([imx]+)?/o.freeze
          StrictRegexpFragment  = /\A#{RegexpFragment}\z/o.freeze

          SingleVariable = /\A\s*([a-zA-Z_0-9]+)\s*\z/om.freeze

          REGEX_OPTIONS = {
            'i' => Regexp::IGNORECASE,
            'm' => Regexp::MULTILINE,
            'x' => Regexp::EXTENDED
          }.freeze

          OPERATORS = %w(all exists gt gte in lt lte ne nin size near within)

          SYMBOL_OPERATORS_REGEXP = /(\w+\.(#{OPERATORS.join('|')})){1}\s*\:/o

          attr_reader :attributes, :attributes_var_name

          def initialize(tag_name, markup, options)
            super

            # convert symbol operators into valid ruby code
            markup.gsub!(SYMBOL_OPERATORS_REGEXP, ':"\1" =>')

            if markup =~ SingleVariable
              # alright, maybe we'vot got a single variable built
              # with the Action liquid tag instead?
              @attributes_var_name = Regexp.last_match(1)
            elsif markup.present?
              # use our own Ruby parser
              @attributes = parse_markup(markup)
            end

            if attributes.blank? && attributes_var_name.blank?
              raise ::Liquid::SyntaxError.new("Syntax Error in 'with_scope' - Valid syntax: with_scope <name_1>: <value_1>, ..., <name_n>: <value_n>")
            end
          end

          def render(context)
            context.stack do
              context['with_scope'] = self.evaluate_attributes(context)

              # for now, no content type is assigned to this with_scope
              context['with_scope_content_type'] = false

              super
            end
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

        ::Liquid::Template.register_tag('with_scope'.freeze, WithScope)

      end
    end
  end
end