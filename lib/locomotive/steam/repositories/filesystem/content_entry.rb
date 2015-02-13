module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class ContentEntry < Struct.new(:loader, :site, :current_locale)

          include Concerns::Queryable

          set_collection model: Filesystem::Models::ContentEntry, sanitizer: Filesystem::Sanitizers::ContentEntry

          # Engine: ???
          def all(type, conditions = {})
            conditions ||= {}

            # TODO: order_by goes here (get settings from the type)

            query(type) do
              where(conditions.merge(_visible: true)).order_by(conditions.delete(:order_by))
            end.all
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

          # Note:
          def association(metadata, conditions = {})
            # only visible entries
            # conditions[:_visible] = true

            # order_by = conditions.delete(:order_by).try(:split)

            # association.filtered(conditions, order_by)
            raise 'TODO filter'
          end

          # Engine: entry.next
          def next(entry)
            raise 'TODO next'
          end

          # Engine: entry.previous
          def previous(entry)
            raise 'TODO previous'
          end

          # Engine: content_type.entries.klass.send(:group_by_select_option, name, content_type.order_by_definition)
          def group_by_select_option(type, name)
            raise 'TODO group_by_select_option'
          end

          # Engine: content_type.entries.klass.send(:"#{name}_options").map { |option| option['name'] }
          def select_options(type, name)
            raise 'TODO select_options'
          end

          private

          def memoized_collection(content_type)
            slug = content_type.slug
            @collections ||= {}

            return @collections[slug] if @collections[slug]

            @collections[slug] = collection(content_type)
          end

        end

      end
    end
  end
end
