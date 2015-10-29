module Locomotive
  module Steam
    module Liquid
      module Tags

        # Blocks are used with the Extends tag to define
        # the content of blocks. Nested blocks are allowed.
        #
        #   {% extends home %}
        #   {% block content }Hello world{% endblock %}
        #
        # Options used to generate the UI/UX of the editable element inputs
        #   - short_name (Boolean): use just the name and skip the name of the nested blocks.
        #   - priority (Integer): allow blocks to be displayed before others
        #
        class InheritedBlock < ::Liquid::InheritedBlock

          def initialize(tag_name, markup, options)
            super

            @attributes = { short_name: false, priority: 0, anchor: true }
            markup.scan(::Liquid::TagAttributes) do |key, value|
              @attributes[key.to_sym] = ::Liquid::Expression.parse(value)
            end
          end

          def parse(tokens)
            super.tap do
              ActiveSupport::Notifications.instrument('steam.parse.inherited_block', {
                page: options[:page],
                name: @name,
                found_super: self.contains_super?(nodelist)
              }.merge(@attributes))
            end
          end

          def render(context)
            (if live_editing?(context) && @attributes[:anchor]
              %{<span class="locomotive-block-anchor" data-element-id="#{@name}" style="visibility: hidden"></span>}
            else
              ''
            end) + super
          end

          protected

          def contains_super?(nodes)
            nodes.any? do |node|
              if is_node_block_super?(node)
                true
              elsif is_node_with_nodelist?(node)
                contains_super?(node.nodelist)
              end
            end
          end

          def is_node_block_super?(node)
            return unless node.is_a?(::Liquid::Variable)

            node.raw.strip == 'block.super'
          end

          def is_node_with_nodelist?(node)
            if node.respond_to?(:nodelist) && !node.is_a?(Locomotive::Steam::Liquid::Tags::InheritedBlock)
              # some blocks does not have a body like the link_to tag
               _nodelist = node.nodelist rescue nil
               !_nodelist.nil?
            end
          end

          def live_editing?(context)
            !!context.registers[:live_editing]
          end

        end

        ::Liquid::Template.register_tag('block'.freeze, InheritedBlock)
      end
    end
  end
end
