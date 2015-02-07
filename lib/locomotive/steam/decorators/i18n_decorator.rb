module Locomotive
  module Steam
    module Decorators

      class I18nDecorator < SimpleDelegator

        attr_accessor :__translated_attributes__
        attr_reader   :__locale__
        attr_reader   :__default_locale__

        def initialize(object, attributes, locale, default_locale = nil)
          self.__translated_attributes__ = attributes
          self.__locale__ = locale
          self.__default_locale__ = default_locale

          super(object)
        end

        def __locale__=(locale)
          @__locale__ = locale.to_sym
        end

        def __default_locale__=(locale)
          @__default_locale__ = locale.try(:to_sym)
        end

        def __with_locale__(locale, &block)
          old_locale, self.__locale__  = __locale__, locale.to_sym
          yield.tap do
            self.__locale__ = old_locale
          end
        end

        def method_missing(name, *args, &block)
          if __translated_attributes__.include?(name.to_sym)
            field = __getobj__.public_send(:attributes)[name.to_sym]
            field[__locale__] || field[__default_locale__] || super
          else
            super
          end
        end

        #:nocov:
        def inspect
          "[Decorated #{__getobj__.class.name}][I18n] " + @__translated_attributes__.inspect + ', locale: ' + @__locale__.inspect
        end


      end

    end
  end
end
