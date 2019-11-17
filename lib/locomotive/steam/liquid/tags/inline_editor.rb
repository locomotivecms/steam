module Locomotive
  module Steam
    module Liquid
      module Tags

        # Add custom CSS and JS to let the logged in users
        # edit their page directly from the page it self.
        #
        # @deprecated
        #
        class InlineEditor < ::Liquid::Tag

          def render(context)
            Locomotive::Common::Logger.warn %(The inline_editor liquid tag is no more used.).yellow
            ''
          end

        end

        ::Liquid::Template.register_tag('inline_editor'.freeze, InlineEditor)

      end
    end
  end
end

