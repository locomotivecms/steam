require 'chronic'

module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class ContentEntry < Base

            set_localized_attributes [:_id, :_slug, :seo_title, :meta_description, :meta_keywords]

            attr_accessor :content_type

            def initialize(attributes = {})
              super({
                _visible:   true,
                _position:  0
              }.merge(attributes))
            end

            def _slug; self[:_slug]; end
            alias :_id :_slug
            alias :_permalink :_slug

            def _label
              self[content_type.label_field_name]
            end

            def [](name)
              is_dynamic_attribute?(name) ? cast_value(name) : super
            end

            def localized_attributes
              self.class.localized_attributes + content_type.localized_fields_names
            end

            private

            def is_dynamic_attribute?(name)
              content_type.fields_by_name.has_key?(name)
            end

            def cast_value(name)
              case (field = content_type.fields_by_name[name]).type
              when :integer   then _cast_value(name, &:to_i)
              when :float     then _cast_value(name, &:to_f)
              when :date      then _cast_value(name) { |v| v.is_a?(String) ? Chronic.parse(v).to_date : v }
              when :date_time then _cast_value(name) { |v| v.is_a?(String) ? Chronic.parse(v).to_datetime : v }
              when :file      then _cast_value(name) { |v| v.present? ? { 'url' => v } : nil }
              when :belongs_to, :has_many, :many_to_many
                AssociationMetadata.new(field.type, self, field, [*attributes[name]])
              else
                attributes[name]
              end
            rescue Exception => e
              Locomotive::Common::Logger.info "[#{content_type.slug}][#{_label}] Unable to cast the \"#{name}\" field, reason: #{e.message}".yellow
              nil
            end

            def _cast_value(name, &block)
              if (value = attributes[name]).is_a?(Hash)
                value.each { |l, _value| value[l] = yield(_value) }
              else
                yield(value)
              end
            end

            class AssociationMetadata < Struct.new(:type, :source, :field, :target_slugs)
              def association; true; end
            end

          end

        end
      end
    end
  end
end
