module Locomotive
  module Steam
    module Liquid

      module Tags

        class SectionsDropzone < ::Liquid::Tag

          include Concerns::Section

          def parse(tokens)
            notify_on_parsing('_sections_dropzone_', is_dropzone: true)
          end

          def render(context)
            sections_dropzone_content = context['page']&.sections_dropzone_content || []

            html = sections_dropzone_content.each_with_index.map do |content, index|
              # find the liquid source of the section
              section = find_section(context, content['type'])

              next if section.nil? # the section doesn't exist anymore?

              # assign a new dom_id to the section if it doesn't have one
              content['id'] = "dropzone-#{index}"

              # parse the template of the section
              template = build_template(section)

              render_section(context, template, section, content)
            end.join

            %(<div class="locomotive-sections">#{html}</div>)
          end

          private

          def find_section(context, type)
            # TODO: add some cache (useful if there are sections with the same type)
            context.registers[:services].section_finder.find(type)
          end

          def build_template(section)
            # TODO: add some cache here (useful if there are sections with the same type)
            ::Liquid::Template.parse(section.liquid_source, parse_context)
          end

        end

        ::Liquid::Template.register_tag('sections_dropzone'.freeze, SectionsDropzone)

      end

    end
  end
end
