module Locomotive
  module Steam
    module Liquid
      module Tags

        # Assign sets a variable in your session.
        #
        #   {% session_assign foo = 'monkey' %}
        #
        # You can then use the variable later in the page.
        #
        #   {{ session.foo }}
        #
        class SessionAssign < ::Liquid::Tag
          Syntax = /(#{::Liquid::VariableSignature}+)\s*=\s*(#{::Liquid::QuotedFragment}+)/o

          def initialize(tag_name, markup, options)
            if markup =~ Syntax
              @to, @from = $1, $2
            else
              raise ::Liquid::SyntaxError.new("Valid syntax: session_assign [var] = [source]")
            end

            super
          end

          def render(context)
            request = context.registers[:request]
            request.session[@to.to_sym] = context[@from]
            ''
          end

        end

        ::Liquid::Template.register_tag('session_assign'.freeze, SessionAssign)
      end
    end
  end
end
