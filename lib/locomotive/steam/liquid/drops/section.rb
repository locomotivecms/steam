module Locomotive
  module Steam
    module Liquid
      module Drops

        class Section < ::Liquid::Drop

          def initialize(section, content)
            @section    = section
            @content    = content

            if @content.blank?
              @content = section.definition['default'] || { 'settings' => {}, 'blocks' => [] }
            end
          end

          # FIXME: id acts as the domID to build HTML tags
          def id
            @content['id']
          end

          def id=(id)
            @content['id'] = id
          end

          def type
            @section.type
          end

          def settings
            @content_proxy ||= SectionContentProxy.new(
              @content['settings'] || {},
              @section.definition['settings'] || []
            )
          end

          def css_class
            @section.definition['class']
          end

          def anchor_id
            "#{@content['anchor'] || id}-section"
          end

          def locomotive_attributes
            %(data-locomotive-section-id="#{id}" data-locomotive-section-type="#{type}").tap do
              # let Steam know that we won't need to wrap the section HTML
              # into an extra DIV layer.
              @context['is_section_locomotive_attributes_displayed'] = true
            end
          end

          def blocks
            build_blocks(@content['blocks'])
          end

          def blocks_as_tree
            [].tap do |root|
              parents = []

              build_blocks(@content['blocks']) do |block, previous_block|
                if block.depth == 0
                  parents = [block]
                  root
                elsif block.depth > previous_block.depth
                  (parents << previous_block).last.leaves
                elsif (diff = previous_block.depth - block.depth) > 0
                  parents[parents.size - diff - 1].tap { parents.pop(diff) }.leaves
                else
                  parents.last.leaves
                end << block
              end
            end
          end

          def editor_setting_data
            SectionEditorSettingData.new(@section)
          end

          private

          def build_blocks(blocks)
            previous_block = nil

            (blocks || []).each_with_index.map do |block, index|
              section_block = SectionBlock.new(@section, block, index)
              yield(section_block, previous_block) if block_given?
              previous_block = section_block
            end
          end

        end

      end
    end
  end
end
