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
        # {% action "My javascript action" %}
        #   var lastPost = allEntries('posts', { 'posted_at.lte': getProp('today'), published: true, order_by: 'posted_at desc' })[0];
        #   var views = lastPost.views + 1;
        #
        #   updateEntry('posts', lastPost._id, { views: views });
        #
        #   setProp('views', views);
        # {% endaction %}
        #
        # <p>Number of views for the last published post: {{ views }}</p>
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
            service(context).run(super, safe_params(context), context)
            ''
          end

          private

          def service(context)
            context.registers[:services].action
          end

          def safe_params(context)
            return {} if context['params'].blank?

            context['params'].dup.tap do |params|
              # Tempfile can't be converted in Duktape for obvious reasons
              replace_tempfile(params)
            end
          end

          def replace_tempfile(hash)
            hash.each do |key, value|
              case value
              when Tempfile then hash[key] = value.path
              when Hash     then replace_tempfile(value)
              end
            end
          end

        end

        ::Liquid::Template.register_tag('action'.freeze, Action)

      end
    end
  end
end

