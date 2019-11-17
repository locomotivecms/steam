module Locomotive
  module Steam
    module Liquid
      module Tags
        class GlobalSection < Locomotive::Steam::Liquid::Tags::Section

          def parse(tokens)
            notify_on_parsing(section_type,
              source:     :site,
              id:         "site-#{section_type}",
              key:        section_type,
              placement:  attributes[:placement]&.to_sym
            )
          end

          private

          def find_section_content(context)
            context['site']&.sections_content&.fetch(section_type, nil)
          end

          def set_section_dom_id(context)
            context['section_id'] = "site-#{section_type}"
          end

        end

        ::Liquid::Template.register_tag('global_section'.freeze, GlobalSection)
      end
    end
  end
end
