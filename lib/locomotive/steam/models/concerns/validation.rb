require 'forwardable'

module Locomotive
  module Steam
    module Models
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

            def_delegators :@messages, :[], :clear, :empty?, :each, :size, :to_hash

            alias_method :blank?, :empty?

            def initialize(base)
              @base     = base
              @messages = HashWithIndifferentAccess.new({})
            end

            def add_on_blank(attribute)
              value = @base.send(attribute)
              add(attribute, :blank) if value.blank?
            end

            def add(attribute, message, options = {})
              (@messages[attribute] ||= []) << generate_message(message, options)
            end

            def generate_message(message, options = {})
              I18n.t(message, {
                scope:    'errors.messages',
                default:  message
              }.merge(options))
            end

          end

        end

      end
    end
  end
end
