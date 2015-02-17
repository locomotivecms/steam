require 'chronic'

module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class ContentEntry < Base

            ASSOCIATION_NAMES = [:belongs_to, :has_many, :many_to_many].freeze

            set_localized_attributes [:_id, :_slug, :seo_title, :meta_description, :meta_keywords]

            attr_accessor :content_type

            def initialize(attributes = {})
              super({
                _visible:     true,
                _position:    0,
                created_at:   Time.now,
                updated_at:   Time.now
              }.merge(attributes))
            end

            def _slug; self[:_slug]; end
            alias :_id :_slug
            alias :_permalink :_slug

            def method_missing(name, *args, &block)
              if is_dynamic_attribute?(name)
                cast_value(name)
              elsif attributes.include?(name)
                self[name]
              else
                super
              end
            end

            def valid?
              errors.clear
              content_type.fields_by_name.each do |name, field|
                next unless field.required?
                errors.add_on_blank(name.to_sym)
              end
              errors.empty?
            end

            def content_type
              @content_type || attributes[:content_type]
            end

            def content_type_slug
              content_type.slug
            end

            def _label
              self[content_type.label_field_name]
            end

            def localized_attributes
              self.class.localized_attributes + content_type.localized_fields_names
            end

            def to_liquid
              Locomotive::Steam::Liquid::Drops::ContentEntry.new(self)
            end

            private

            def is_dynamic_attribute?(name)
              content_type.fields_by_name.has_key?(name)
            end

            def cast_value(name)
              field = content_type.fields_by_name[name]

              begin
                _cast_value(field)
              rescue Exception => e
                Locomotive::Common::Logger.info "[#{content_type.slug}][#{_label}] Unable to cast the \"#{name}\" field, reason: #{e.message}".yellow
                nil
              end
            end

            def _cast_value(field)
              if ASSOCIATION_NAMES.include?(field.type)
                AssociationMetadata.new(field.type, self, field, [*attributes[field.name]])
              elsif private_methods.include?(:"_cast_#{field.type}")
                send(:"_cast_#{field.type}", field.name)
              else
                attributes[field.name]
              end
            end

            def _cast_integer(name)
              _cast_convertor(name, &:to_i)
            end

            def _cast_float(name)
              _cast_convertor(name, &:to_f)
            end

            def _cast_file(name)
              _cast_convertor(name) do |value|
                value.present? ? { 'url' => value } : nil
              end
            end

            def _cast_date(name)
              _cast_time(name, :to_date)
            end

            def _cast_date_time(name)
              _cast_time(name, :to_date)
            end

            def _cast_time(name, end_method)
              _cast_convertor(name) do |value|
                value.is_a?(String) ? Chronic.parse(value).send(end_method) : value
              end
            end

            def _cast_convertor(name, &block)
              if (value = attributes[name]).is_a?(Hash)
                value.each { |l, _value| value[l] = yield(_value) }
              else
                yield(value)
              end
            end

            class AssociationMetadata < Struct.new(:type, :source, :field, :target_slugs)
              def association; true; end
              def inverse_of; field.inverse_of; end
              def target_class_slug; field.class_name; end
              def order_by; field[:order_by]; end
            end

          end

        end
      end
    end
  end
end
