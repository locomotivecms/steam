module Locomotive
  module Steam
    module Services
      module Concerns

        module Decorator

          private

          def decorate(&block)
            if (object = yield).blank?
              object
            else
              Decorators::TemplateDecorator.decorate(object, nil, locale, default_locale)
            end
          end

          def locale
            repository.current_locale
          end

          def default_locale
            repository.site.default_locale
          end

        end

      end
    end
  end
end
