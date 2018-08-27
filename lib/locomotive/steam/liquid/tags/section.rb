module Locomotive
  module Steam
    module Liquid
      module Tags
        class Section < ::Liquid::Include

          include Concerns::Section

          def initialize(tag_name, markup, options)
            if markup =~ /(#{::Liquid::QuotedString}|#{::Liquid::VariableSignature}+)\s*,*(.*)?/o
              @section_type, _options = $1, $2
              raw_options       = parse_options_from_string(_options)
              @section_options  = interpolate_options(raw_options, {})
              super
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'section' - Valid syntax: section section_type, id: '<string>', placement: 'top|bottom' (id and placement are optional)")
            end
          end

          def parse(tokens)
            notify_on_parsing(evaluate_section_name,
              id:         "page-#{@section_options[:id] || evaluate_section_name}",
              key:        @section_options[:id] || evaluate_section_name,
              label:      @section_options[:label],
              placement:  @section_options[:placement]&.to_sym
            )
          end

          def render(context)
            # @options doesn't include the page key if cache is on
            @options[:page] = context.registers[:page]

            # get the type/slug of the section
            # @section_options  = interpolate_options(@raw_section_options, context)
            @section_type     = evaluate_section_name(context)
            @template_name    = "sections-#{@section_type}"

            section   = find_section(context)
            template  = load_cached_partial(context)

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
            context['section_id'] = "page-#{@section_options[:id] || @section_type}"
          end

          def read_template_from_file_system(context)
            section = find_section(context)
            raise SectionNotFound.new("Section with slug '#{@section_type}' was not found") if section.nil?
            section.liquid_source
          end

          def find_section(context)
            context.registers[:services].section_finder.find(@section_type)
          end

          def find_section_content(context)
            section_id = @section_options[:id].presence || @section_type
            context['page']&.sections_content&.fetch(section_id, nil)
          end

          def evaluate_section_name(context = nil)
            context.try(:evaluate, @template_name) ||
            (!@template_name.is_a?(String) && @template_name.send(:state).first) ||
            @template_name
          end

        end

        ::Liquid::Template.register_tag('section'.freeze, Section)
      end
    end
  end
end
