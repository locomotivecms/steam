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

      def parse_string(string)
        Locomotive::Steam::Liquid::Template.parse(string,
          snippet_finder: snippet_finder,
          parser:         self)
      end

      def _parse(object, options = {})
        # Note: the template must not be parsed here
        begin
          Locomotive::Steam::Liquid::Template.parse(object.liquid_source, options)
        rescue ::Liquid::Error => e
          raise Locomotive::Steam::RenderError.new(e, object.template_path, object.liquid_source)
        end
      end

    end

  end
end
