module Locomotive
  module Steam
    module Liquid
      module Drops
        class I18nBase < Base

          def initialize(source, localized_attributes = [])
            decorated = Locomotive::Steam::Decorators::I18nDecorator.new(source, localized_attributes)
            super(decorated)
          end

          def context=(context)
            if locale = context.registers[:locale]
              @_source.__locale__ = locale
            end

            @_source.__default_locale__ = context.registers[:site].default_locale

            super
          end

          private

          def _change_locale(locale)
            @_source.__locale__ = locale
          end

          def _change_locale!(locale)
            @_source.__locale__ = locale
            @_source.__freeze_locale__
          end

        end
      end
    end
  end
end
