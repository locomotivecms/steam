module Locomotive
  module Steam
    module Decorators

      class I18nDecorator < SimpleDelegator

        # attr_accessor :__localized_attributes__
        attr_accessor :__frozen_locale__
        attr_reader   :__locale__
        attr_reader   :__default_locale__

        def initialize(object, locale = nil, default_locale = nil)
          # ::Object.send(:puts, "Decorating #{object.class.name} with #{self.class.name}")

          # self.__localized_attributes__ = attributes || (object.respond_to?(:localized_attributes) ? object.localized_attributes : [])
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

        def __is_localized_attribute__(name)
          # __localized_attributes__.include?(name.to_sym)
          field = __getobj__.public_send(name.to_sym)
          field.respond_to?(:__translations__)
        end

        def __get_localized_value__(name)
          field = __getobj__.public_send(name.to_sym)
          field[__locale__] || field[__default_locale__]

          # # first get all the values in all the locales
          # field = __getobj__.public_send(name.to_sym)

          # # same value (can be nil) for all the locale?
          # if field.respond_to?(:__translations__)
          #   # if so, look first for the value in the the current locale.
          #   # if no value, then in the default locale
          #   field[__locale__] || field[__default_locale__]
          # else
          #   field
          # end
        end

        def __set_localized_value__(name, value)
          field = __getobj__.public_send(name.to_sym)
          binding.pry
          field[__locale__] || field[__default_locale__]

          # field = __getobj__.public_send(name.to_sym)

          # if field.respond_to?(:__translations__)
          #   field[__locale__] = value
          # else
          #   field = value }
          # end
        end

        def method_missing(name, *args, &block)
          ::Object.send(:puts, "YOUPI (1) #{name.inspect} #{args.inspect}")
          # # ::Object.send(:puts, "[#{name}][#{__locale__.inspect}][#{__default_locale__.inspect}] with #{args.inspect}") # DEBUG:

          if name.to_s.end_with?('=') && __is_localized_attribute__(name.to_s.chop)
            ::Object.send(:puts, "YOUPI (2)")
            __set_localized_value__(name.to_s.chop, args.first)
          elsif __is_localized_attribute__(name)
            __get_localized_value__(name)
          else
            # Note: we want to hit the method_missing of the target object
            __getobj__.send(name, *args, &block)
          end


          # if __is_localized_attribute__(name)
          #   __get_localized_value__(name)
          # elsif name.to_s.end_with?('=') && __is_localized_attribute__(name.to_s.chop)
          #   ::Object.send(:puts, "YOUPI (2)")
          #   __set_localized_value__(name.to_s.chop, args.first)
          # else
          #   # Note: we want to hit the method_missing of the target object
          #   __getobj__.send(name, *args, &block)
          # end
        end

        #:nocov:
        def inspect
          "[Decorated #{__getobj__.class.name}][I18n] attributes exist? " +
          __getobj__.respond_to?(:attributes).inspect +
          # ', localized attributes: ' + @__localized_attributes__.inspect +
          ', locale: ' + @__locale__.inspect
        end

      end

    end
  end
end
