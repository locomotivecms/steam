module Locomotive
  module Steam
    module Liquid
      class PageNotFound < ::Liquid::Error; end

      class SnippetNotFound < ::Liquid::Error; end

      class SectionNotFound < ::Liquid::Error; end

      class PageNotTranslated < ::Liquid::Error; end
    end
  end
end
