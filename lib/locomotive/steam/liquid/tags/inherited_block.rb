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
        class InheritedBlock < ::Liquid::Block

          include Concerns::Attributes

          SYNTAX = /(#{::Liquid::QuotedFragment}+)/o

          attr_reader :name

          # linked chain of inherited blocks included
          # in different templates if multiple extends
          attr_accessor :parent, :descendant

          def initialize(tag_name, markup, options)
            super

            if markup =~ SYNTAX
              @name = Regexp.last_match(1).gsub(/["']/o, '').strip
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'block' - Valid syntax: block <name>")
            end

            prepare_for_inheritance

            parse_attributes(markup, short_name: false, priority: 0, anchor: true)
          end

          def prepare_for_inheritance
            # give a different name if this is a nested block
            if (block = inherited_blocks[:nested].last)
              @name = "#{block.name}/#{@name}"
            end

            # append this block to the stack in order to
            # get a name for the other nested inherited blocks
            inherited_blocks[:nested].push(self)

            # build the linked chain of inherited blocks
            # make a link with the descendant and the parent (chained list)
            if (descendant = inherited_blocks[:all][@name])
              self.descendant   = descendant
              descendant.parent = self

              # get the value of the blank property from the descendant
              @blank = descendant.blank?
            end

            # become the descendant of the inherited block from the parent template
            inherited_blocks[:all][@name] = self
          end

          def parse(tokens)
            super

            # when the parsing of the block is done, we can then remove it from the stack
            inherited_blocks[:nested].pop.tap do
              ActiveSupport::Notifications.instrument('steam.parse.inherited_block', {
                page: parse_context[:page],
                name: name,
                found_super: self.contains_super?(nodelist)
              }.merge(raw_attributes))
            end
          end

          alias_method :render_without_inheritance, :render

          def render(context)
            context.stack do
              # look for the very first descendant
              block = self_or_first_descendant

              # the block drop is in charge of rendering "{{ block.super }}"
              context['block'] = Drops::InheritedBlock.new(block)
              anchor_html = if live_editing?(context) && (raw_attributes[:anchor] || raw_attributes[:anchor].nil?)
                %{<span class="locomotive-block-anchor" data-element-id="#{name}" style="visibility: hidden"></span>}
              else
                ''
              end

              anchor_html + block.render_without_inheritance(context)
            end
          end

          # when we render an inherited block, we need the version of the
          # very first descendant.
          def self_or_first_descendant
            block = self
            while block.descendant; block = block.descendant; end
            block
          end

          def call_super(context)
            if parent
              # remove the block from the linked chain
              parent.descendant = nil

              parent.render(context)
            else
              ''
            end
          end

          def inherited_blocks
            # initialize it in the case the template does not include an extend tag
            options[:inherited_blocks] ||= { all: {}, nested: [] }
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

        ::Liquid::Template.register_tag('block', InheritedBlock)
      end
    end
  end
end
