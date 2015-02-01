require 'RedCloth'

module Locomotive
  module Steam
    module Services

      class Textile

        def to_html(text)
          return '' if text.blank?

          ::RedCloth.new(text).to_html
        end

      end

    end
  end
end
