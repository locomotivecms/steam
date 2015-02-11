module Locomotive
  module Steam
    module Liquid
      module Tags

        # Add custom CSS and JS to let the logged in users
        # edit their page directly from the page it self.
        #
        # @deprecated
        #
        class InlineEditor < Solid::Tag

          tag_name :inline_editor

          def display
            Locomotive::Common::Logger.warn %(The inline_editor liquid tag is no more used.).yellow
            ''
          end

        end

      end
    end
  end
end

