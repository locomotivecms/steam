module Locomotive
  module Steam
    module Liquid
      module Tags

        class RedirectTo < ::Liquid::Tag

          include Concerns::I18nPage
          include Concerns::Path

          def render(context)
            if (path = render_path(context)).present?
              # 301 or 302 redirection
              is_permanent = @path_options[:permanent].nil? ? true : @path_options[:permanent]

              # break the rendering process
              raise Locomotive::Steam::RedirectionException.new(path, permanent: is_permanent)
            end
            ''
          end

          def wrong_syntax!
            raise SyntaxError.new("Valid syntax: redirect_to <page|page_handle|content_entry|external_url>(, locale: [fr|de|...], with: <page_handle>, permanent: [true|false]")
          end

        end

        ::Liquid::Template.register_tag('redirect_to'.freeze, RedirectTo)

      end
    end
  end
end
