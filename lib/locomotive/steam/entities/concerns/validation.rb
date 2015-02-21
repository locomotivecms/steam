require 'forwardable'

module Locomotive
  module Steam
    module Entities
      module Concerns

        module Validation

          def errors
            @errors ||= Errors.new(self)
          end

          def valid?
            true
          end

          class Errors

            include Enumerable
            extend Forwardable

            attr_accessor :messages

            def_delegators :@messages, :[], :clear, :empty?, :each, :size

            alias_method :blank?, :empty?

            def initialize(base)
              @base     = base
              @messages = HashWithIndifferentAccess.new({})
            end

            def add_on_blank(attribute)
              value = @base.send(attribute)
              add(attribute, :blank) if value.blank?
            end

            def add(attribute, message)
              (@messages[attribute] ||= []) << generate_message(message)
            end

            def generate_message(message)
              case message
              when :blank, :unique then I18n.t(message, scope: 'errors.messages')
              else
                message
              end
            end

          end

        end

      end
    end
  end
end
