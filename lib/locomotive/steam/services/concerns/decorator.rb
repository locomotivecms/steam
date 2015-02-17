module Locomotive
  module Steam
    module Services
      module Concerns

        module Decorator

          private

          def decorate(klass = Decorators::TemplateDecorator, &block)
            if (object = yield).blank?
              object
            else
              klass.decorate(object, nil, locale, default_locale)
            end
          end

          def i18n_decorate(&block)
            decorate(Decorators::I18nDecorator, &block)
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
