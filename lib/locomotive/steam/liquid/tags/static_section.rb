require_relative './section.rb'
module Locomotive
  module Steam
    module Liquid
      module Tags
        class StaticSection < Locomotive::Steam::Liquid::Tags::Section

          private

          def find_section_content(context)
            context['site']&.sections_content&.fetch(@section_type, nil)
          end

        end
        ::Liquid::Template.register_tag('static_section'.freeze, StaticSection)
      end
    end
  end
end
