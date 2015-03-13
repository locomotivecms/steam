require_relative 'i18n_decorator'

module Locomotive
  module Steam
    module Decorators

      class TemplateDecorator < I18nDecorator

        def liquid_source
          if respond_to?(:template_path)
            source_from_template_file
          else
            self.source
          end
        end

        private

        def source_from_template_file
          source = File.open(template_path).read.force_encoding('utf-8')

          if match = source.match(FRONTMATTER_REGEXP)
            source = match[:template]
          end

          if template_path.ends_with?('.haml')
            Haml::Engine.new(source).render
          else
            source
          end
        end

      end

    end
  end
end
