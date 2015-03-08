require 'RedCloth'

module Locomotive
  module Steam

    class TextileService

      def to_html(text)
        return '' if text.blank?

        ::RedCloth.new(text).to_html
      end

    end

  end
end
