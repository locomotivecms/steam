module Locomotive::Steam
  module Middlewares
    class Section < ThreadSafe

      include Concerns::Helpers
      include Concerns::LiquidContext

      def _call
        if section_type = get_section_type
          html = render(section_type)
          render_response(html, 200)
        end
      end

      private

      def get_section_type
        request.get_header('HTTP_LOCOMOTIVE_SECTION_TYPE')
      end

      def render(section_type)
        document = Liquid::Template.parse(liquid_source(section_type))
        document.render(liquid_context)
      end

      def liquid_source(section_type)
        "{% section '#{section_type}' %}"
      end

      def liquid_registers
        super.merge(_section_content: section_content)
      end

      def section_content
        # looks like request.body is not always in the right state,
        # the following statement makes sure of it.
        request.body.rewind

        if (data = request.body.read).present?
          JSON.parse(data)['section_content']
        else
          {}
        end
      end

      def live_editing?
        true
      end

    end
  end
end
