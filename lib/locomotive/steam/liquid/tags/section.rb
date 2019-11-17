module Locomotive
  module Steam
    module Liquid
      module Tags
        class Section < ::Liquid::Include

          include Concerns::Section
          include Concerns::Attributes

          Syntax = /(#{::Liquid::QuotedString}|#{::Liquid::VariableSignature}+)\s*,*(.*)?/o.freeze

          attr_reader :section_type

          def initialize(tag_name, markup, options)
            super

            if markup =~ Syntax
              @section_type, _attributes = $1, $2
              @template_name_expr = @section_type.gsub!(/['"]/, '')

              parse_attributes(_attributes)
            end
          end

          def parse(tokens)
            notify_on_parsing(section_type,
              id:         "page-#{attributes[:id] || section_type}",
              key:        (attributes[:id] || section_type).to_s,
              label:      attributes[:label],
              placement:  attributes[:placement]&.to_sym
            )
          end

          def render(context)
            evaluate_attributes(context)

            # the context (parsing) doesn't include the page key if cache is on
            parse_context[:page] = context.registers[:page]

            # use the Liquid filesystem to get the template of the section
            template = parse_template(section_type, context)

            # fetch the section definition
            section = find_section(context)

            # if the tag is called by the Section middleware, use the content
            # from the request.
            content = context.registers[:_section_content]

            # if no content from the middleware, go get it from the page
            content ||= find_section_content(context)

            context.stack do
              set_section_dom_id(context)
              render_section(context, template, section, content)
            end
          end

          private

          def set_section_dom_id(context)
            context['section_id'] = "page-#{attributes[:id] || section_type}"
          end

          def find_section(context)
            context.registers[:services].section_finder.find(section_type)
          end

          def find_section_content(context)
            section_id = attributes[:id].presence || section_type
            context['page']&.sections_content&.fetch(section_id, nil)
          end

          def parse_template(section_type, context)
            ::Liquid::PartialCache.load(
              "sections--#{section_type}",
              context:        context,
              parse_context:  parse_context
            )
          end

        end

        ::Liquid::Template.register_tag('section'.freeze, Section)
      end
    end
  end
end
