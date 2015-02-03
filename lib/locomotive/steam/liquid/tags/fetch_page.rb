module Locomotive
  module Steam
    module Liquid
      module Tags

        # Fetch a page from its handle and assign it to a liquid variable.
        #
        # Usage:
        #
        # {% fetch_page about_us as a_page %}
        # <p>{{ a_page.title }}</p>
        #
        class FetchPage < ::Liquid::Tag

          Syntax = /(#{::Liquid::VariableSignature}+)\s+as\s+(#{::Liquid::VariableSignature}+)/

          def initialize(tag_name, markup, options)
            if markup =~ Syntax
              @handle, @var = $1, $2
            else
              raise SyntaxError.new("Syntax Error in 'fetch_page' - Valid syntax: fetch_page page_handle as variable")
            end

            super
          end

          def render(context)
            page = context.registers[:repositories].page.by_handle(@handle)
            context.scopes.last[@var] = page
            ''
          end
        end

        ::Liquid::Template.register_tag('fetch_page'.freeze, FetchPage)
      end
    end
  end
end
