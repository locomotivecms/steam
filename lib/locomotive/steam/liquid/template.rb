module Locomotive
  module Steam
    module Liquid

      class Template < ::Liquid::Template

        # When we render a Locomotive template, we need to know what are
        # the default content of all the editable elements.
        # Without this, developers are unable to use statements like
        # the following: {{ page.editable_elements.content.header.title }}
        def render(*args)
          if args.first && args.first.is_a?(::Liquid::Context)
            content = @options[:default_editable_content]
            args.first.registers[:default_editable_content] = content
          end

          super
        end

        class << self

          def parse(source, options = {})
            template = new
            template.parse(source, options)
          end

        end

      end

    end
  end
end
