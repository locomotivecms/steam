module Locomotive
  module Steam
    module Decorators

      class I18nDecorator < SimpleDelegator

        attr_accessor :__localized_attributes__
        attr_accessor :__frozen_locale__
        attr_reader   :__locale__
        attr_reader   :__default_locale__

        def initialize(object, attributes, locale = nil, default_locale = nil)
          self.__localized_attributes__ = attributes || (object.respond_to?(:localized_attributes) ? object.localized_attributes : [])
          self.__frozen_locale__        = false
          self.__locale__               = locale
          self.__default_locale__       = default_locale

          super(object)
        end

        class << self

          def decorate(object_or_list, attributes = nil, locale = nil, default_locale = nil)
            decorated = [[object_or_list]].flatten.map do |object|
              new(object, attributes, locale, default_locale)
            end

            object_or_list.respond_to?(:attributes) ? decorated.first : decorated
          end

        end

        def __locale__=(locale)
          unless self.__frozen_locale__
            @__locale__ = locale.try(:to_sym)
          end
        end

        def __default_locale__=(locale)
          @__default_locale__ = locale.try(:to_sym)
        end

        def __with_locale__(locale, &block)
          old_locale, self.__locale__  = __locale__, locale.to_sym
          self.__freeze_locale__
          yield.tap do
            self.__unfreeze_locale__
            self.__locale__ = old_locale
          end
        end

        def __freeze_locale__
          @__frozen_locale__ = true
        end

        def __unfreeze_locale__
          @__frozen_locale__ = false
        end

        def method_missing(name, *args, &block)
          # DEBUG: ::Object.send(:puts, "[#{name}] with #{args.inspect}")
          if __localized_attributes__.include?(name.to_sym)
            field = __getobj__.public_send(:attributes)[name.to_sym]
            field[__locale__] || field[__default_locale__] || super
          else
            super
          end
        end

        #:nocov:
        def inspect
          "[Decorated #{__getobj__.class.name}][I18n] attributes exist? " +
          __getobj__.respond_to?(:attributes).inspect +
          ', localized attributes: ' + @__localized_attributes__.inspect +
          ', locale: ' + @__locale__.inspect
        end

      end

    end
  end
end
