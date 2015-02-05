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
              yield
            end
          end

          protected

          def decode(options)
            HashWithIndifferentAccess.new.tap do |hash|
              options.each do |key, value|
                # _slug instead of _permalink
                _key = key.to_s == '_permalink' ? '_slug' : key.to_s

                hash[_key] = (case value
                  # regexp inside a string
                when /^\/[^\/]*\/$/ then Regexp.new(value[1..-2])
                else
                  value
                end)
              end
            end
          end
        end

      end
    end
  end
end
