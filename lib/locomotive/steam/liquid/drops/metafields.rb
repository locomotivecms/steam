module Locomotive
  module Steam
    module Liquid
      module Drops

        class MetafieldsNamespace < Base

          delegate :first, :last, :each, :each_with_index, :empty?, :any?, :size, to: :labels_and_values

          alias :count    :size
          alias :length   :size

          def liquid_method_missing(meth)
            find_value(meth.to_s)
          end

          def namespace=(namespace)
            @namespace = namespace
          end

          protected

          def find_value(name)
            if field = fields[name]
              safe_value(t(values[name], field['localized']), field['type'])
            else
              Locomotive::Common::Logger.warn "[Liquid template] unknown site metafield \"#{name}\" under #{@namespace['name']}"
              nil
            end
          end

          def values
            @_source.metafields[@namespace['name']] || {}
          end

          def labels_and_values
            return [] if @namespace['fields'].blank?

            return @labels_and_values if @labels_and_values

            ordered_fields = @namespace['fields'].sort { |a, b| a['position'] <=> b['position'] }

            @labels_and_values = ordered_fields.map do |field|
              value, localized = values[field['name']], field['localized']
              {
                'name'  => field['name'],
                'label' => t(field['label']) || field['name'].humanize,
                'value' => safe_value(t(value, localized))
              }
            end
          end

          def fields
            return @fields if @fields

            (@fields = {}).tap do
              (@namespace['fields'] || []).each do |field|
                @fields[field['name']] = field
              end
            end
          end

          def t(value, localized = true)
            key   = localized ? @context.registers[:locale] : 'default'
            value = { 'default' => value } unless value.is_a?(Hash)
            value[key]
          end

          def safe_value(value, type = 'string')
            case type
            when 'boolean'
              ['1', 'true', true].include?(value) ? true : false
            else
              value.blank? ? nil : value
            end
          end

        end

        class Metafields < Base

          def liquid_method_missing(meth)
            find_namespace(meth.to_s)
          end

          private

          def find_namespace(name)
            if namespace = _find_namespace(name)
              MetafieldsNamespace.new(@_source).tap { |d| d.namespace = namespace }
            else
              Locomotive::Common::Logger.warn "[Liquid template] unknown site metafield namespace \"#{name}\""
              nil
            end
          end

          def _find_namespace(name)
            @_source.metafields_schema.find { |s| s['name'] == name }
          end

        end

      end
    end
  end
end
