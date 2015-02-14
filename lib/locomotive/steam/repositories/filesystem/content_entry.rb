module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class ContentEntry < Struct.new(:loader, :site, :current_locale, :content_type_repository)

          include Concerns::Queryable

          set_collection model: Filesystem::Models::ContentEntry, sanitizer: Filesystem::Sanitizers::ContentEntry

          # Engine: ???
          def all(type, conditions = {})
            conditions = { _visible: true }.merge(conditions || {})

            # priority:
            # 1/ order_by passed in the conditions parameter
            # 2/ the default order (_position) defined in the content type
            order_by = conditions.delete(:order_by) || type.order_by

            query(type) do
              where(conditions).order_by(order_by)
            end.all
          end

          # Engine: not necessary
          def by_slug(type, slug)
            query(type) { where(_slug: slug) }.first
          end

          # Engine: entry.name :-)
          def value_for(name, entry, conditions = {})
            value = entry.send(name)

            if value.respond_to?(:association)
              association(value, conditions || {})
            else
              value
            end
          end

          # Engine: entry.next
          def next(entry)
            next_or_previous(entry, 'gt', 'lt')
          end

          # Engine: entry.previous
          def previous(entry)
            next_or_previous(entry, 'lt', 'gt')
          end

          # Engine: content_type.entries.klass.send(:group_by_select_option, name, content_type.order_by_definition)
          def group_by_select_option(type, name)
            return {} if type.nil? || name.nil? || type.fields_by_name[name].type != :select

            _groups = all(type).group_by(&name)

            groups = content_type_repository.select_options(type, name).map do |option|
              { name: option, entries: _groups.delete(option) || [] }
            end

            unless _groups.blank?
              groups << (empty = { name: nil, entries: [] })
              _groups.values.each { |list| empty[:entries] += list }
            end

            groups
          end

          private

          def type_from(slug)
            content_type_repository.by_slug(slug)
          end

          def localized_slug(entry)
            localized_attribute(entry, :_slug)
          end

          def association(metadata, conditions = {})
            case metadata.type
            when :belongs_to    then belongs_to_association(metadata)
            when :has_many      then has_many_association(metadata, conditions)
            when :many_to_many  then many_to_many_association(metadata, conditions)
            end
          end

          def belongs_to_association(metadata)
            type = type_from(metadata.target_class_slug)
            by_slug(type, metadata.target_slugs.first)
          end

          def has_many_association(metadata, conditions)
            many_association(metadata,
              { metadata.target_field => localized_slug(metadata.source) }.merge(conditions))
          end

          def many_to_many_association(metadata, conditions)
            many_association(metadata,
              { '_slug.in' => metadata.target_slugs }.merge(conditions))
          end

          def many_association(metadata, conditions)
            type = type_from(metadata.target_class_slug)

            if order_by = metadata.order_by
              conditions = { order_by: order_by }.merge(conditions)
            end

            all(type, conditions)
          end

          def memoized_collection(content_type)
            slug = content_type.slug
            @collections ||= {}

            return @collections[slug] if @collections[slug]

            @collections[slug] = collection(content_type)
          end

          def next_or_previous(entry, asc_op, desc_op)
            return nil if entry.nil?

            type      = entry.content_type
            column, direction = type.order_by.split
            operator  = direction == 'asc' ? asc_op : desc_op
            value     = localized_attribute(entry, column)

            query(type) { where("#{column}.#{operator}" => value) }.first
          end

        end

      end
    end
  end
end
