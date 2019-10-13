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

        # assign an id if specified in the context
        context['section'].id ||= context['section_id'] if context['section_id'].present?

        begin
          _render(context, template)
        rescue Locomotive::Steam::ParsingRenderingError => e
          e.template_name = section.name + ' [Section]'
          raise e
        end
      end
    end

    def _render(context, template)
      if context.registers[:live_editing]
        editor_settings_lookup(template.root)
      end

      html = template.render_to_output_buffer(context, '')

      # by default, Steam will wrap the section HTML to make sure it has all the
      # DOM attributes the live editing editor needs.
      if context['is_section_locomotive_attributes_displayed']
        html
      else
        wrap_html(html, context)
      end
    end

    def wrap_html(html, context)
      section     = context['section']
      css_class   = context['section_css_class']

      # we need the section_css_class once
      # context.scopes.last.delete('section_css_class')

      anchor_id = %(id="#{section.anchor_id}")
      tag_id    = %(id="locomotive-section-#{section.id}")
      tag_class = %(class="#{['locomotive-section', section.css_class, css_class].compact.join(' ')}")
      tag_data  = %(data-locomotive-section-type="#{section.type}")

      %(<div #{tag_id} #{tag_class} #{tag_data}><span #{anchor_id}></span>#{html}</div>)
    end

    # in order to enable string/text synchronization with the editor:
    # - find variables like {{ section.settings.<id> }} or {{ block.settings.<id> }}
    # - once found, get the closest tag
    # - add custom data attributes to it
    def editor_settings_lookup(root)
      previous_node = nil
      new_nodelist  = []

      root.nodelist.each_with_index do |node, index|
        if node.is_a?(::Liquid::Variable) && previous_node.is_a?(String)
          matches = node.raw.match(Locomotive::Steam::SECTIONS_SETTINGS_VARIABLE_REGEXP)

          # is a section setting variable?
          if matches && matches[:id] && wrapped_around_tag?(index, root.nodelist)
            # open the closest HTML tag
            previous_node.gsub!(/>(\s*)\z/, '\1')

            # here we go, add a liquid variable!
            new_nodelist.push(::Liquid::Variable.new(
              "section.editor_setting_data.#{matches[:id]}",
              node.parse_context) #instance_variable_get(:@options))
            )

            # close the tag
            new_nodelist.push('>') #::Liquid::Tokenizer.new('>', previous_node.line_number))
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

      return false unless next_node.is_a?(String)

      (previous_node =~ /\>\s*\z/).present? && (next_node =~ /\A\s*\</).present?
    end

    def notify_on_parsing(type, source: :page, is_dropzone: false, key: nil, id: nil, label: nil, placement: nil)
      ActiveSupport::Notifications.instrument('steam.parse.section', {
        attributes: {
          type:         type,
          source:       source,
          id:           id,
          key:          key,
          is_dropzone:  is_dropzone,
          label:        label,
          placement:    placement
        },
        page:   options[:page],
        block:  current_inherited_block_name
      })
    end

    def current_inherited_block_name
      options[:inherited_blocks].try(:[], :nested).try(:last).try(:name)
    end

  end

end
