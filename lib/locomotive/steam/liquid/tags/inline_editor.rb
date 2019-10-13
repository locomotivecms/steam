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

          def render_to_output_buffer(context, output)
            Locomotive::Common::Logger.warn %(The inline_editor liquid tag is no more used.).yellow
            output
          end

        end

        ::Liquid::Template.register_tag('inline_editor'.freeze, InlineEditor)

      end
    end
  end
end

