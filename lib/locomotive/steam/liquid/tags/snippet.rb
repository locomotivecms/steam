module Locomotive
  module Steam
    module Liquid
      module Tags

        class Snippet < ::Liquid::Include

          attr_reader :name

          def initialize(tag_name, markup, options)
            super

            # we use a convention to differentiate sections from snippets
            @name               = evaluate_snippet_name
            @template_name_expr = "snippets--#{@name}"
          end

          def parse(tokens)
            ActiveSupport::Notifications.instrument('steam.parse.include', page: parse_context[:page], name: name)

            # look for editable elements (only used by the Engine)
            # In the next version of Locomotive (v5), we won't support the editable elements
            if parse_context[:snippet_finder] && snippet = parse_context[:snippet_finder].find(name)
              parse_context[:parser]._parse(snippet, parse_context.merge(snippet: name))
            end
          end

          def render_to_output_buffer(context, output)
            # parse_context (previously @options) doesn't include the page key if cache is on
            parse_context[:page] = context.registers[:page]

            super
          end

          private

          def evaluate_snippet_name
            (!template_name_expr.is_a?(String) && template_name_expr.send(:state).first) ||
            template_name_expr
          end

        end

        ::Liquid::Template.register_tag('include'.freeze, Snippet)
      end
    end
  end
end
