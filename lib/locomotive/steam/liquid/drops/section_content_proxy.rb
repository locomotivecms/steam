module Locomotive
  module Steam
    module Liquid
      module Drops

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
            when 'url'  then SectionUrlField.new(*url_for(value))
            when 'text' then decode_urls_for(value)
            else value
            end
          end

          private

          def decode_urls_for(value)
            value.gsub(Locomotive::Steam::SECTIONS_LINK_TARGET_REGEXP) do
              decodedUrl = Base64.decode64($~[:link])
              _value = JSON.parse(decodedUrl)
              url_for(_value)[0]
            end
          end

          def url_for(value)
            return value if value.is_a?(String)

            _value = value || {}

            [_url_for(_value['type'], _value['value']), _value['new_window'] || false]
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

        class SectionUrlField < ::Liquid::Drop

          def initialize(url, new_window = false)
            @url, @new_window = url, new_window
          end

          def new_window
            @new_window
          end

          def to_s
            @url
          end

        end

      end
    end
  end
end
