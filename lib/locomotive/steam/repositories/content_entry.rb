module Locomotive
  module Steam
    module Repositories

      class ContentEntry < Struct.new(:site)

        def all(content_type, conditions = {})
          # TODO
        end

        def group_by_select_option(content_type, name)
          klass = content_type.entries.klass
          order = content_type.order_by_definition

          klass.send(:group_by_select_option, name, order)
        end

        def select_options(content_type, name)
          klass = content_type.entries.klass
          klass.send(:"#{name}_options").map { |option| option['name'] }
        end

      end

    end
  end
end
