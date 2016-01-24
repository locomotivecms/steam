module Locomotive
  module Steam
    module Liquid
      module Drops

        class Metafields < Base

          def before_method(meth)
            if field = fields[meth.to_s]
              find_value(meth.to_s, field)
            else
              Locomotive::Common::Logger.warn "[Liquid template] unknown site metafield \"#{meth.to_s}\""
              nil
            end
          end

          private

          def find_value(name, field)
            value = @_source.metafields[name]

            return nil if value.blank?

            key   = field['localized'] ? @context.registers[:locale] : 'default'
            value = { 'default' => value } unless value.is_a?(Hash)

            value[key]
          end

          def fields
            return @schema if @schema

            (@schema = {}).tap do
              @_source.metafields_schema.each do |definition|
                definition['fields'].each do |field|
                  @schema[field['name']] = field
                end
              end
            end
          end

        end

      end
    end
  end
end
