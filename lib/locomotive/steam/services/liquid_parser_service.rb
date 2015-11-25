module Locomotive
  module Steam

    class LiquidParserService

      attr_accessor_initialize :parent_finder, :snippet_finder

      def parse(page)
        _parse(page,
          page:                       page,
          parent_finder:              parent_finder,
          snippet_finder:             snippet_finder,
          parser:                     self,
          default_editable_content:   {})
      end

      def _parse(object, options = {})
        # Note: the template must not be parsed here
        Locomotive::Steam::Liquid::Template.parse(object.liquid_source, options)
      end

    end

  end
end
