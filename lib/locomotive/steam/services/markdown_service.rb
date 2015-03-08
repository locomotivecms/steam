require 'kramdown'

module Locomotive
  module Steam

    class MarkdownService

      def to_html(text)
        return '' if text.blank?

        Kramdown::Document.new(text, auto_ids: false).to_html
      end

    end

  end
end
