module Locomotive::Steam
  module Adapters
    module MongoDB

      class Query

        def initialize(scope, localized_attributes, &block)
          @query = ::Origin::Query.new
          @scope = scope
          @localized_attributes = localized_attributes

          apply_default_scope

          instance_eval(&block) if block_given?
        end

        def where(criterion = nil)
          @query = @query.where(criterion)
          self
        end

        def order_by(*args)
          @query = @query.order_by(*args)
          self
        end

        def selector
          @query.selector
        end

        private

        def apply_default_scope
          where(site_id: @scope.site._id) if @scope.site
        end

      end

    end
  end
end
