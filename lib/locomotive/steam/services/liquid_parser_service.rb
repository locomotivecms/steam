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
        begin
          Locomotive::Steam::Liquid::Template.parse(object.liquid_source, options)
        rescue Locomotive::Steam::TemplateError => e
          # we don't want to hide an exception occured during parsing a section or a snippet
          raise e
        rescue ::Liquid::Error => e
          raise Locomotive::Steam::LiquidError.new(e, object.template_path, object.liquid_source)
        end
      end

    end

  end
end
