require 'haml'
require_relative 'i18n_decorator'

module Locomotive
  module Steam
    module Decorators

      class TemplateDecorator < I18nDecorator

        def liquid_source
          if respond_to?(:template_path) && template_path
            source_from_template_file
          else
            self.source
          end
        end

        private

        def source_from_template_file
          source = File.read(template_path).force_encoding('utf-8')

          if match = source.match(FRONTMATTER_REGEXP)
            source = match[:template]
          end

          if template_path.ends_with?('.haml')
            render_haml(source, template_path)
          else
            source
          end
        end

        def render_haml(source, template_path)
          begin
            Haml::Engine.new(source).render
          rescue Haml::SyntaxError => e
            raise Steam::RenderError.new(e.message, template_path, source, e.line, e.backtrace)
          end
        end

      end

    end
  end
end
