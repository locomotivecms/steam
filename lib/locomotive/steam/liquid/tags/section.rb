module Locomotive
  module Steam
    module Liquid
      module Tags
        class Section < ::Liquid::Include

          def render(context)
            # @options doesn't include the page key if cache is on
            @options[:page] = context.registers[:page]
            if find_section(context).definition[:default]
              context['section'] = find_section(context).definition[:default] # | mongoDB content if exists
            end
            begin
              super
            rescue Locomotive::Steam::ParsingRenderingError => e
              e.file = @template_name + ' [Section]'
              raise e
            end
          end

          private

          def read_template_from_file_system(context)
            section = find_section(context)

            raise SectionNotFound.new("Section with slug '#{@template_name}' was not found") if section.nil?

            section.liquid_source
          end

          private

          def find_section(context)
            context.registers[:services].section_finder.find(@template_name)
          end

        end


        ::Liquid::Template.register_tag('section'.freeze, Section)
      end
    end
  end
end
