module Locomotive
  module Steam
    module Liquid
      module Tags
        class Extends < ::Liquid::Extends

          def render(context)
            context.stack do
              context['layout_name'] = @layout_name
              super
            end
          end

          private

          def parse_parent_template
            parent = options[:parent_finder].find(options[:page], @template_name)

            # no need to go further if the parent does not exist
            raise PageNotFound.new("Extending a missing page. Page/Layout with fullpath '#{@template_name}' was not found") if parent.nil?

            ActiveSupport::Notifications.instrument('steam.parse.extends', page: options[:page], parent: parent)

            # define the layout name which is basically the handle of the parent page
            # if there is no handle, we take the slug which might or might not be localized.
            @layout_name = parent.handle || parent.slug

            # the source has already been parsed before
            options[:parser]._parse(parent, options.merge(page: parent))
          end

        end

        ::Liquid::Template.register_tag('extends'.freeze, Extends)
      end
    end
  end
end
