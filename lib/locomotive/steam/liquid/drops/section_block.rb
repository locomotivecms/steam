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
            @definition = section.definition['blocks'].find do |block|
              block['type'] == type
            end
          end

          def id
            @block['id'] || @index
          end

          def type
            @block['type']
          end

          def settings
            @content_proxy ||= SectionContentProxy.new(
              @block['settings'] || {},
              @definition['settings'] || []
            )
          end

          def locomotive_attributes
            if @context.registers[:live_editing]
              value = "section-#{@context['section'].id}-block-#{id}"
              %(data-locomotive-block="#{value}")
            else
              ''
            end
          end

        end

      end
    end
  end
end
