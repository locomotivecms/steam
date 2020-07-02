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

          include Concerns::Attributes

          # Regexps and Arrays are allowed
          ArrayFragment         = /\[(\s*(#{::Liquid::QuotedFragment},\s*)*#{::Liquid::QuotedFragment}\s*)\]/o.freeze
          RegexpFragment        = /\/([^\/]+)\/([imx]+)?/o.freeze
          StrictRegexpFragment  = /\A#{RegexpFragment}\z/o.freeze

          # a slight different from the Shopify implementation because we allow stuff like `started_at.le`
          TagAttributes   = /([a-zA-Z_0-9\.]+)\s*\:\s*(#{ArrayFragment}|#{RegexpFragment}|#{::Liquid::QuotedFragment})/o.freeze
          SingleVariable  = /(#{::Liquid::VariableSignature}+)/om.freeze

          REGEX_OPTIONS = {
            'i' => Regexp::IGNORECASE,
            'm' => Regexp::MULTILINE,
            'x' => Regexp::EXTENDED
          }.freeze

          attr_reader :attributes, :attributes_var_name

          def initialize(tag_name, markup, options)
            super

            # simple hash?
            parse_attributes(markup) { |value| parse_attribute(value) }

            if attributes.empty? && markup =~ SingleVariable
              # alright, maybe we'vot got a single variable built
              # with the Action liquid tag instead?
              @attributes_var_name = Regexp.last_match(1)
            end

            if attributes.empty? && attributes_var_name.blank?
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

          def parse_attribute(value)
            case value
            when StrictRegexpFragment
              # let the cast_value attribute create the Regexp (done during the rendering phase)
              value
            when ArrayFragment
              $1.split(',').map { |_value| parse_attribute(_value) }
            else
              ::Liquid::Expression.parse(value)
            end
          end

          def evaluate_attributes(context)
            @attributes = context[attributes_var_name] || {} if attributes_var_name.present?

            HashWithIndifferentAccess.new.tap do |hash|
              attributes.each do |key, value|
                # _slug instead of _permalink
                _key = key.to_s == '_permalink' ? '_slug' : key.to_s

                # evaluate the value if possible before casting it
                _value = value.is_a?(::Liquid::VariableLookup) ? context.evaluate(value) : value

                hash[_key] = cast_value(context, _value) unless _value.nil?
              end
            end
          end

          def cast_value(context, value)
            case value
            when Array                then value.map { |_value| cast_value(context, _value) }
            when StrictRegexpFragment then create_regexp($1, $2)
            else
              _value = context.evaluate(value)
              _value.respond_to?(:_id) ? _value.send(:_source) : _value
            end
          end

          def create_regexp(value, unparsed_options)
            options = unparsed_options.blank? ? nil : unparsed_options.split('').uniq.inject(0) do |_options, letter|
              _options |= REGEX_OPTIONS[letter]
            end
            Regexp.new(value, options)
          end

          def tag_attributes_regexp
            TagAttributes
          end

        end

        ::Liquid::Template.register_tag('with_scope'.freeze, WithScope)

      end
    end
  end
end
