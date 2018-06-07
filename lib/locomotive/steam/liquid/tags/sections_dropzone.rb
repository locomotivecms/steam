module Locomotive
  module Steam
    module Liquid

      module Tags

        class SectionsDropzone < ::Liquid::Tag

          include Concerns::Section

          def parse(tokens)
            ActiveSupport::Notifications.instrument('steam.parse.sections_dropzone')
          end

          def render(context)
            section_contents = context['page']&.sections_content || []

            html = section_contents.each_with_index.map do |content, index|
              # find the liquid source of the section
              section = find_section(context, content['type'])

              next if section.nil? # the section doesn't exist anymore?

              # assign a new id to the section
              content['id'] = index

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
            ::Liquid::Template.parse(section.liquid_source, @options)
          end

        end

        ::Liquid::Template.register_tag('sections_dropzone'.freeze, SectionsDropzone)

      end

    end
  end
end
