require 'kramdown'

module Locomotive
  module Steam
    module Services
      class Markdown

        def render(text)
          self.class.parser.render(text)
        end

        # http://kramdown.gettalong.org/options.html
        def self.parser
          @@markdown ||= Kramdown::Document.new(text).to_html
        end

      end
    end
  end
end