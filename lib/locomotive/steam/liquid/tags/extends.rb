module Locomotive
  module Steam
    module Liquid
      module Tags

        # Extends allows designer to use template inheritance.
        #
        #   {% extends home %}
        #   {% block content }Hello world{% endblock %}
        #
        class Extends < ::Liquid::Block
          SYNTAX = /(#{::Liquid::QuotedFragment}+)/o

          def initialize(tag_name, markup, options)
            super

            if markup =~ SYNTAX
              @template_name = Regexp.last_match(1).gsub(/["']/o, '').strip
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'extends' - Valid syntax: extends <page_handle_or_parent_keyword>")
            end

            # variables needed by the inheritance mechanism during the parsing
            options[:inherited_blocks] ||= {
              nested: [], # used to get the full name of the blocks if nested (stack mechanism)
              all: {}, # keep track of the blocks by their full name
            }
          end

          def parse(tokens)
            super

            parent_template = parse_parent_template

            # replace the nodes of the current template by those from the parent
            # which itself may have have done the same operation if it includes
            # the extends tag.
            nodelist.replace(parent_template.root.nodelist)
          end

          def blank?
            false
          end

          def render(context)
            context.stack do
              context['layout_name'] = @layout_name
              super
            end
          end

          protected

          def parse_body(body, tokens)
            body.parse(tokens, options) do |end_tag_name, _|
              @blank &&= body.blank?

              # Note: extends does not require the "end tag".
              return false if end_tag_name.nil?
            end

            true
          end

          def parse_parent_template
            parent = parse_context[:parent_finder].find(parse_context[:page], @template_name)

            # no need to go further if the parent does not exist
            raise Liquid::PageNotFound.new("Extending a missing page. Page/Layout with fullpath '#{@template_name}' was not found") if parent.nil?

            ActiveSupport::Notifications.instrument('steam.parse.extends', page: parse_context[:page], parent: parent)

            # define the layout name which is basically the handle of the parent page
            # if there is no handle, we take the slug which might or might not be localized.
            @layout_name = parent.handle || parent.slug

            # the source has already been parsed before
            parse_context[:parser]._parse(parent, parse_context.merge(page: parent))
          end
        end

        ::Liquid::Template.register_tag('extends', Extends)
      end
    end
  end
end
