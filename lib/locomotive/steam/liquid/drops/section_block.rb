module Locomotive
  module Steam
    module Liquid
      module Drops

        # Section block drop
        class SectionBlock < ::Liquid::Drop

          def initialize(section, block, index)
            @section    = section
            @block      = block || { 'settings' => {} }
            @index      = index
            @leaves     = []
            @definition = section.definition['blocks'].find do |block|
              block['type'] == type
            end || {}
          end

          def id
            @block['id'] || @index
          end

          def type
            @block['type']
          end

          def depth
            @block['depth'].presence || 0
          end

          def leaves
            @leaves
          end

          def has_leaves?
            leaves.size > 0
          end

          def settings
            @content_proxy ||= SectionContentProxy.new(
              @block['settings'] || {},
              @definition['settings'] || []
            )
          end

          def locomotive_attributes
            value = "section-#{@context['section'].id}-block-#{id}"
            %(data-locomotive-block="#{value}")
          end

        end

      end
    end
  end
end
