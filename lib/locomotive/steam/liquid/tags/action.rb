module Locomotive
  module Steam
    module Liquid
      module Tags

        # Execute javascript code server side.
        # The API allows you to:
        # - access the current liquid context
        # - modify the session
        # - send emails
        # - find / create / update content entries
        #
        # Usage:
        #
        # {% action "" %}
        #   {% for post in blog.posts %}
        #     {{ post.title }}
        #   {% endfor %}
        # {% endconsume %}
        #
        class Action < ::Liquid::Block

          Syntax = /(#{::Liquid::QuotedString}+)/o

          def initialize(tag_name, markup, options)
            if markup =~ Syntax
              @description = $1.to_s
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'action' - Valid syntax: action \"<description>\"")
            end
            super
          end

          def render(context)
            Locomotive::Common::Logger.info "[action] executing #{@description}"
            service(context).run(super, context['params'], context)
            ''
          end

          private

          def service(context)
            context.registers[:services].action
          end

        end

        ::Liquid::Template.register_tag('action'.freeze, Action)

      end
    end
  end
end

