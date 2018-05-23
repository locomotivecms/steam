module Locomotive::Steam
  module Middlewares
    class Section < ThreadSafe

      include Helpers
      include LiquidContext

      def _call
        if section_id = get_section_id(env['PATH_INFO'])
          html = render(section_id)
          render_response(html, 200)
        end
      end

      private

      def get_section_id(path_info)
        matchs = path_info.match(/^\/_sections\/(?<section_id>[a-z0-9]+$)/)
        matchs['section_id'] if matchs
      end

      def section_finder
        services.section_finder
      end

      def render(section_id)
        liquid_source = "{% section '#{section_id}' %}"
        document = Liquid::Template.parse liquid_source
        document.render(liquid_context)
      end
    end
  end
end
