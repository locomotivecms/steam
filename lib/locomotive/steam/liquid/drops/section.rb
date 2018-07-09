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

          def id
            @content['id'] || @section.type
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

          def blocks
            (@content['blocks'] || []).each_with_index.map do |block, index|
              SectionBlock.new(@section, block, index)
            end
          end

          def editor_setting_data
            SectionEditorSettingData.new(@section)
          end

        end

        # Represent the content of a section or a block
        # This abstraction is required to handle content manipulation
        # based on field setting type (url for instance).
        class SectionContentProxy < ::Liquid::Drop

          def initialize(content, settings)
            @content, @settings = content, settings
          end

          def before_method(name)
            value = @content[name.to_s]

            case type_of(name)
            when 'url'  then url_for(value)
            when 'text' then decode_urls_for(value)
            else value
            end
          end

          private

          def decode_urls_for(value)
            value.gsub(Locomotive::Steam::SECTIONS_LINK_TARGET_REGEXP) do
              decodedUrl = Base64.decode64($~[:link])
              _value = JSON.parse(decodedUrl)
              url_for(_value)
            end
          end

          def url_for(value)
            return value if value.is_a?(String)

            _value = value || {}

            _url_for(_value['type'], _value['value'])
          end

          def _url_for(type, value)
            page = case type
            when 'page'
              page_finder_service.find_by_id(value)
            when 'content_entry'
              # find the page template
              page_finder_service.find_by_id(value['page_id']).tap do |_page|
                entry = content_entry_service.find(value['content_type_slug'], value['id'])

                return nil if _page.nil? || entry.nil?

                # attach the template to the content entry
                _page.content_entry = entry
              end
            else
              nil
            end

            page ? url_builder_service.url_for(page) : value
          end

          def type_of(name)
            setting_of(name).try(:[], 'type')
          end

          def setting_of(name)
            @settings.find { |setting| setting['id'] == name.to_s }
          end

          def page_finder_service
            @context.registers[:services].page_finder
          end

          def content_entry_service
            @context.registers[:services].content_entry
          end

          def url_builder_service
            @context.registers[:services].url_builder
          end

        end

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
            value = "section-#{@context['section'].id}-block-#{id}";
            %(data-locomotive-block="#{value}")
          end

        end

        # Required to allow the sync between the Locomotive editor
        # and the string/text inputs of a section and section block
        class SectionEditorSettingData < ::Liquid::Drop

          def initialize(section)
            @section = section
          end

          def before_method(meth)
            block   = nil
            prefix  = "section-#{@context['section'].id}"
            matches = (@context['forloop.name'] || '').match(SECTIONS_BLOCK_FORLOOP_REGEXP)

            # are we inside a block?
            if matches && variable_name = matches[:name]
              block = @context[variable_name]
              prefix += "-block.#{block.id}"
            end

            # only string and text inputs can synced
            if is_text?(meth.to_s, block)
              %( data-locomotive-editor-setting="#{prefix}.#{meth}")
            else
              ''
            end
          end

          private

          def is_text?(id, block)
            settings = block ? block_settings(block['type']) : section_settings

            # can happen if the developer forgets to assign a type to
            # the default blocks
            return false if settings.blank?

            text_inputs(settings).include?(id)
          end

          def text_inputs(settings)
            settings.map do |input|
              %w(text textarea).include?(input['type']) ? input['id'] : nil
            end.compact
          end

          def block_settings(type)
            @section.definition['blocks'].find do |block|
              block['type'] == type
            end&.fetch('settings', nil)
          end

          def section_settings
            @section.definition['settings']
          end
        end

      end
    end
  end
end
