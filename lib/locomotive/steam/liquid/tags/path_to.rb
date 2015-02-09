module Locomotive
  module Steam
    module Liquid
      module Tags
        class PathTo < ::Liquid::Tag

          include Concerns::I18nPage
          include Concerns::Path

          def render(context)
            render_path(context)
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
