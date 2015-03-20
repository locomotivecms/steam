module Locomotive::Steam
  module Adapters
    module MongoDB

      class Query

        attr_reader :criteria, :sort

        def initialize(scope, localized_attributes, &block)
          @criteria, @sort, @fields, @skip, @limit = {}, nil, nil, nil, nil
          @scope, @localized_attributes = scope, localized_attributes

          apply_default_scope

          instance_eval(&block) if block_given?
        end

        def where(criterion = nil)
          self.tap do
            @criteria.merge!(criterion) unless criterion.nil?
          end
        end

        def order_by(*args)
          self.tap do
            @sort = [*args]
          end
        end

        def only(*args)
          self.tap do
            @fields = [*args]
          end
        end

        def offset(offset)
          self.tap { @skip = offset }
        end

        def limit(limit)
          self.tap { @limit = limit }
        end

        def against(collection)
          _query = to_origin
          selector, fields, sort = _query.selector, _query.options[:fields], _query.options[:sort]

          collection.find(selector).tap do |results|
            results.sort(sort)      if sort
            results.select(fields)  if fields
            results.skip(@skip)     if @skip
            results.limit(@limit)   if @limit
          end
        end

        def to_origin
          build_origin_query.only(@fields).where(@criteria).order_by(*@sort)
        end

        private

        def build_origin_query
          ::Origin::Query.new(build_aliases(@localized_attributes, @scope.locale))
        end

        def build_aliases(localized_attributes, locale)
          localized_attributes.inject({}) do |aliases, name|
            aliases.tap do
              aliases[name.to_s] = "#{name}.#{locale}"
            end
          end
        end

        def apply_default_scope
          where(site_id: @scope.site._id) if @scope.site
        end

      end

    end
  end
end
