module Locomotive
  module Steam
    module Liquid
      module Tags
        class PathTo < ::Liquid::Tag

          include Concerns::Attributes
          include Concerns::I18nPage
          include Concerns::Path

          def render_to_output_buffer(context, output)
            output << render_path(context)
            output
          end

          def wrong_syntax!
            raise SyntaxError.new("Valid syntax: path_to <page|page_handle|content_entry>(, locale: [fr|de|...], with: <page_handle>")
          end

        end

        ::Liquid::Template.register_tag('path_to'.freeze, PathTo)
      end
    end
  end
end
