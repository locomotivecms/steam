module Locomotive::Steam::Liquid::Tags::Concerns

  module Section

    private

    def render_section(context, template, section, content)
      context.stack do
        # build a drop from the content and add it to the new context
        context['section'] = Locomotive::Steam::Liquid::Drops::Section.new(
          section,
          content
        )

        begin
          _render(context, template)
        rescue Locomotive::Steam::ParsingRenderingError => e
          e.file = section.name + ' [Section]'
          raise e
        end
      end
    end

    def _render(context, template)
      if context.registers[:live_editing]
        editor_settings_lookup(template.root)
      end

      context.stack do
        html    = template.render(context)
        section = context['section']

        tag_id    = %(id="locomotive-section-#{section.id}")
        tag_class = %(class="#{['locomotive-section', section.css_class].compact.join(' ')}")
        tag_data  = %(data-locomotive-section-type="#{section.type}")

        %(<div #{tag_id} #{tag_class} #{tag_data}>#{html}</div>)
      end
    end

    # in order to enable string/text synchronization with the editor:
    # - find variables like {{ section.settings.<id> }} or {{ block.settings.<id> }}
    # - once found, get the closest tag
    # - add custom data attributes to it
    def editor_settings_lookup(root)
      previous_node = nil
      new_nodelist  = []

      return if root.nodelist.blank?

      root.nodelist.each_with_index do |node, index|
        if node.is_a?(::Liquid::Variable) && previous_node.is_a?(::Liquid::Token)
          matches = node.raw.match(Locomotive::Steam::SECTIONS_SETTINGS_VARIABLE_REGEXP)

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

      (root.instance_variable_get(:@body) || root).instance_variable_set(:@nodelist, new_nodelist)
    end

    def wrapped_around_tag?(index, nodelist)
      return false if index + 1 >= nodelist.size

      previous_node = nodelist[index - 1]
      next_node     = nodelist[index + 1]

      return false unless next_node.is_a?(::Liquid::Token)

      (previous_node =~ /\>\s*\z/).present? && (next_node =~ /\A\s*\</).present?
    end

  end

end
