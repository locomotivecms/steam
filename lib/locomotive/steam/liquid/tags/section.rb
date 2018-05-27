module Locomotive
  module Steam
    module Liquid
      module Tags
        class Section < ::Liquid::Include

          def parse(tokens)
            ActiveSupport::Notifications.instrument('steam.parse.section', name: evaluate_section_name)
          end

          def render(context)
            # @options doesn't include the page key if cache is on
            @options[:page] = context.registers[:page]

            # 1. get the type/slug of the section
            @section_type   = evaluate_section_name(context)
            @template_name  = "sections-#{@section_type}"

            # 2. get the section
            section = find_section(context)

            # 3. if the tag is called by the Section middleware, use the content
            # from the request.
            section_content = context.registers[:_section_content]

            # 4. since it's considered as static and if no content, get the
            # content from the current site.
            section_content ||= context['site']&.sections_content&.fetch(@section_type, nil)

            puts section_content.inspect

            # 5. enhance the context by setting the "section" variable
            context['section'] = Locomotive::Steam::Liquid::Drops::Section.new(
              section,
              section_content
            )

            begin
              _render(context)
            rescue Locomotive::Steam::ParsingRenderingError => e
              e.file = @template_name + ' [Section]'
              raise e
            end
          end

          private

          def _render(context)
            partial = load_cached_partial(context)

            if context.registers[:live_editing]
              editor_settings_lookup(partial.root)
            end

            context.stack do
              html = partial.render(context)

              tag_id    = "locomotive-section-#{context['section'].id}"
              tag_class = ['locomotive-section', context['section'].css_class].join(' ')

              %(<div id="#{tag_id}" class="#{tag_class}">#{html}</div>)
            end
          end

          # in order to enable string/text synchronization with the editor:
          # - find variables like {{ section.settings.<id> }} or {{ block.settings.<id> }}
          # - once found, get the closest tag
          # - add custom data attributes to it
          def editor_settings_lookup(root)
            previous_node = nil
            new_nodelist  = []

            root.nodelist.each_with_index do |node, index|
              if node.is_a?(::Liquid::Variable) && previous_node.is_a?(::Liquid::Token)
                matches = node.raw.match(SECTIONS_SETTINGS_VARIABLE_REGEXP)

                # is a section setting variable?
                if matches && matches[:id] && wrapped_around_tag?(index, root.nodelist)
                  # open the closest HTML tag
                  previous_node.gsub!(/>(\s*)\z/, '\1')

                  # here we go, add a liquid variable!
                  new_nodelist.push(::Liquid::Variable.new(
                    "section.editor_setting_data.#{matches[:id]}",
                    node.instance_variable_get(:@options))
                  )

                  # close the tag
                  new_nodelist.push(::Liquid::Token.new('>', previous_node.line_number))
                end
              elsif node.respond_to?(:nodelist)
                editor_settings_lookup(node)
              end

              new_nodelist.push(node)

              previous_node = node
            end

            root.instance_variable_set(:@nodelist, new_nodelist)
          end

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

          def wrapped_around_tag?(index, nodelist)
            return false if index + 1 >= nodelist.size

            previous_node = nodelist[index - 1]
            next_node     = nodelist[index + 1]

            return false unless next_node.is_a?(::Liquid::Token)

            (previous_node =~ /\>\s*\z/).present? && (next_node =~ /\A\s*\</).present?
          end

        end

        ::Liquid::Template.register_tag('section'.freeze, Section)
      end
    end
  end
end
