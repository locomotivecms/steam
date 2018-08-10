module Locomotive
  module Steam
    module Liquid
      module Tags
        class Section < ::Liquid::Include

          include Concerns::Section

          def initialize(tag_name, markup, options)
            if markup =~ /(#{::Liquid::VariableSignature}+)(\s*,.+)?/o
              @section_type, _options = $1, $2
              @raw_section_options = parse_options_from_string(_options)
            else
              self.wrong_syntax!
            end
            super
          end

          def parse(tokens)
            ActiveSupport::Notifications.instrument('steam.parse.section', name: evaluate_section_name)
          end

          def render(context)
            # @options doesn't include the page key if cache is on
            @options[:page] = context.registers[:page]

            # get the type/slug of the section
            @section_options  = interpolate_options(@raw_section_options, context)
            @section_type     = evaluate_section_name(context)
            @template_name    = "sections-#{@section_type}"
            @section_id       = @section_type + (@section_options[:id].nil? ? '' : "-#{@section_options[:id]}")

            section   = find_section(context)
            template  = load_cached_partial(context)

            # if the tag is called by the Section middleware, use the content
            # from the request.
            content = context.registers[:_section_content]

            content ||= context['page']&.sections_content&.fetch(@section_id, nil)

            if @section_id && !content.nil?
              content['id'] = @section_id
            end
            render_section(context, template, section, content)
          end

          private

          def read_template_from_file_system(context)
            section = find_section(context)
            raise SectionNotFound.new("Section with slug '#{@section_type}' was not found") if section.nil?
            section.liquid_source
          end

          def find_section(context)
            context.registers[:services].section_finder.find(@section_type)
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
