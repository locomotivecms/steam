module Locomotive
  module Steam

    # This service is used for the following use cases:
    # - get an url of a link encoded by the RichTextEditor component in the engine
    # - get an url of a link created through the UrlPicker component in the engine
    #
    class UrlFinderService

      attr_accessor_initialize :url_builder, :page_finder, :content_entry_finder

      # Return an array with the following elements: [<URL>, <NEW_WINDOW>]
      #
      # Example:
      # url_for({
      #   'type'        => 'page',
      #   'value'       =>  '42', # id of the home page
      #   'locale'      => 'en',
      #   'new_window'  => true
      # })
      #
      # will return: ['/', true]
      #
      def url_for(resource)
        return [resource, false] if resource.is_a?(String)

        _resource = resource || {}
        page      = find_page(_resource['type'], _resource['value'])

        [
          page ? url_builder.url_for(page) : _resource['value'],
          _resource['new_window'] || false
        ]
      end

      # Same behavior as for url_for except the parameter is a
      # JSON string encoded in Base64
      def decode_url_for(encoded_value)
        url_for(decode_link(encoded_value))
      end

      # Apply the decode_url_for method for each link of a text
      def decode_urls_for(text)
        text.gsub(Locomotive::Steam::SECTIONS_LINK_TARGET_REGEXP) do
          decode_url_for($~[:link])[0]
        end
      end

      # Decode a link
      def decode_link(encoded_value)
        decoded_value = Base64.decode64(encoded_value)
        JSON.parse(decoded_value)
      end

      private

      # Based on the type of the resource, it returns either:
      # - a simple page
      # - a templatized page with its related content entry attached
      # - nil if external url
      def find_page(type, value)
        case type
        when 'page'
          page_finder.find_by_id(value)
        when 'content_entry'
          # find the page template
          page_finder.find_by_id(value['page_id']).tap do |_page|
            entry = content_entry_finder.find(value['content_type_slug'], value['id'])

            return nil if _page.nil? || entry.nil?

            # attach the template to the content entry
            _page.content_entry = entry
          end
        else
          nil
        end
      end

    end

  end
end
