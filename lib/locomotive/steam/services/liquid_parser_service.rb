module Locomotive
  module Steam

    class LiquidParserService < Struct.new(:parent_finder, :snippet_finder)

      def parse(page, events_listener = nil)
        _parse(page,
          page:             page,
          events_listener:  events_listener,
          parent_finder:    parent_finder,
          snippet_finder:   snippet_finder,
          parser:           self)
      end

      def _parse(object, options = {})
        # Note: the template must not be parsed here
        ::Liquid::Template.parse(object.liquid_source, options)
      end

    end

  end
end
