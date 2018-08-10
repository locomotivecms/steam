require_relative './section.rb'
module Locomotive
  module Steam
    module Liquid
      module Tags
        class StaticSection < Locomotive::Steam::Liquid::Tags::Section


          #TODO CLEAN RENDER
          def render(context)
            # @options doesn't include the page key if cache is on
            @options[:page] = context.registers[:page]

            # get the type/slug of the section
            @section_type   = evaluate_section_name(context)
            @template_name  = "sections-#{@section_type}"

            section   = find_section(context)
            template  = load_cached_partial(context)

            # if the tag is called by the Section middleware, use the content
            # from the request.
            content = context.registers[:_section_content]

            # since it's considered as static and if no content, get the
            # content from the current site.
            content ||= context['site']&.sections_content&.fetch(@section_type, nil)

            render_section(context, template, section, content)
          end

        end
        ::Liquid::Template.register_tag('static_section'.freeze, StaticSection)
      end
    end
  end
end
