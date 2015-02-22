module Locomotive::Steam
  module Adapters
    module Filesystem

      module Sanitizer

        extend Forwardable

        def_delegators :@scope, :site, :locale, :locales, :default_locale

        attr_reader :scope

        def setup(scope)
          @scope = scope
          self
        end

        def with(scope, &block)
          setup(scope)
          yield(self)
        end

        def apply_to(entity_or_dataset)
          if entity_or_dataset.respond_to?(:all)
            apply_to_dataset(entity_or_dataset)
          else
            apply_to_entity(entity_or_dataset)
          end
        end

        def apply_to_dataset(dataset)
          dataset
        end

        def apply_to_entity(entity)
          entity
        end

        alias :current_locale :locale

      end

    end
  end
end
