require 'pry'
module Locomotive
  module Steam
    module Liquid
      module Tags
        class Section < ::Liquid::Include

          def parse(tokens)
            ActiveSupport::Notifications.instrument('steam.parse.section', name: @template_name)
          end

          def render(context)
            # @options doesn't include the page key if cache is on
            @options[:page] = context.registers[:page]

            # 1. get the name/slug of the section
            @template_name = evaluate_section_name(context)

            # 2. get the section
            section = find_section(context)

            # 3. because it's considered as a static section, go get the content from
            # the current site. If it doesn't exist, use the default attribute of
            # the section
            section_content = context['site']&.sections_content&.fetch(@template_name, nil) #context["site"].sections[@template_name]

            if section_content.blank?
              section_content = section.definition[:default] || {}
            end

            # 4. enhance the context by setting the "section" variable
            context['section'] = section_content

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

          def find_section(context)
            context.registers[:services].section_finder.find(@template_name)
          end

          # Repeat snippet
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
