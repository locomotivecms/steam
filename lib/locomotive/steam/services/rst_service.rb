require 'github/markup'

module Locomotive
  module Steam

    class RstService

      def to_html(text)
        return '' if text.blank?

        GitHub::Markup.render(".rst", text)
      end

    end

  end
end
