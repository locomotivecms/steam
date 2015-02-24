module Locomotive::Steam
  module Adapters
    module MongoDB

      class Query

        attr_reader :criteria, :sort

        def initialize(scope, localized_attributes, &block)
          @criteria, @sort = {}, nil
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
          @sort = [*args]
        end

        def against(collection)
          _query = to_origin
          selector, sort = _query.selector, _query.options[:sort]

          if sort
            collection.find(selector).sort(sort)
          else
            collection.find(selector)
          end
        end

        def to_origin
          build_origin_query.where(@criteria).order_by(*@sort)
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

        # def resolve_key(key)
        #   return key unless key.respond_to?(:include?)
        #   if key.include?('.')
        #     name, operator = key.split('.')
        #     name.to_sym.send(operator.to_sym)
        #   else
        #     key
        #   end
        # end

      end

    end
  end
end
