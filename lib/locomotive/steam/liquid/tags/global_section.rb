module Locomotive
  module Steam
    module Liquid
      module Tags
        class GlobalSection < Locomotive::Steam::Liquid::Tags::Section

          def parse(tokens)
            notify_on_parsing(evaluate_section_name,
              source:     :site,
              id:         "site-#{evaluate_section_name}",
              key:        evaluate_section_name,
              placement:  @section_options[:placement]&.to_sym
            )
          end

          private

          def find_section_content(context)
            context['site']&.sections_content&.fetch(@section_type, nil)
          end

          def set_section_dom_id(context)
            context['section_id'] = "site-#{@section_type}"
          end

        end

        ::Liquid::Template.register_tag('global_section'.freeze, GlobalSection)
      end
    end
  end
end
