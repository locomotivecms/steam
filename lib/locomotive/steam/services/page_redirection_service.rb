module Locomotive
  module Steam

    class PageRedirectionService

      attr_accessor_initialize :page_finder, :url_builder

      def redirect_to(handle, locale = nil)
        if page_url = url_to(handle, locale)
          raise Locomotive::Steam::RedirectionException.new(page_url)
        else
          false
        end
      end

      private

      def url_to(handle, locale)
        if page = page_finder.by_handle(handle)
          url = url_builder.url_for(page, locale)
        else
          false
        end
      end

    end

  end
end
