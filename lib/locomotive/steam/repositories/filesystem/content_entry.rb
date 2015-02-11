module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class ContentEntry < Struct.new(:site)

          def all(type, conditions = {})
            # TODO
            raise 'TODO all'
          end

          def filter(association, conditions = {})
            # only visible entries
            # conditions[:_visible] = true

            # order_by = conditions.delete(:order_by).try(:split)

            # association.filtered(conditions, order_by)

            raise 'TODO filter'
          end

          def next(entry)
            # entry.next
            raise 'TODO next'
          end

          def previous(entry)
            # entry.previous
            raise 'TODO previous'
          end

          def group_by_select_option(type, name)
            # klass = content_type.entries.klass
            # order = content_type.order_by_definition

            # klass.send(:group_by_select_option, name, order)
            raise 'TODO group_by_select_option'
          end

          def select_options(type, name)
            # klass = content_type.entries.klass
            # klass.send(:"#{name}_options").map { |option| option['name'] }
            raise 'TODO select_options'
          end

        end

      end
    end
  end
end
