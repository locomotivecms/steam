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

        class WithScope < Solid::Block

          OPERATORS = %w(all exists gt gte in lt lte ne nin size near within)

          SYMBOL_OPERATORS_REGEXP = /(\w+\.(#{OPERATORS.join('|')})){1}\s*\:/o

          REGEX_OPTIONS = {
            'i' => Regexp::IGNORECASE,
            'm' => Regexp::MULTILINE,
            'x' => Regexp::EXTENDED
          }

          # register the tag
          tag_name :with_scope

          def initialize(name, markup, options)
            # convert symbol operators into valid ruby code
            markup.gsub!(SYMBOL_OPERATORS_REGEXP, ':"\1" =>')

            super(name, markup, options)
          end

          def display(options = {}, &block)
            current_context.stack do
              current_context['with_scope'] = self.decode(options)
              current_context['with_scope_content_type'] = false # for now, no content type is assigned to this with_scope
              yield
            end
          end

          protected

          def decode(options)
            HashWithIndifferentAccess.new.tap do |hash|
              options.each do |key, value|
                # _slug instead of _permalink
                _key = key.to_s == '_permalink' ? '_slug' : key.to_s

                hash[_key] = cast_value(value)
              end
            end
          end

          def cast_value(value)
            case value
            when Array then value.map { |_value| cast_value(_value) }
            when /^\/([^\/]*)\/([imx]+)?$/
              _value, options_str = $1, $2
              options = options_str.blank? ? nil : options_str.split('').uniq.inject(0) do |_options, letter|
                _options |= REGEX_OPTIONS[letter]
              end
              Regexp.new(_value, options)
            else
              value.respond_to?(:_id) ? value.send(:_source) : value
            end
          end

        end

      end
    end
  end
end
