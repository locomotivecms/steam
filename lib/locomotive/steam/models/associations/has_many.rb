module Locomotive::Steam
  module Models

    # Note: represents an embedded collection
    class HasManyAssociation < ReferencedAssociation

      def __load__
        # Note: in adapters like the FileSystem one, we use slugs
        # to reference other entities in associations.
        id  = @repository.i18n_value_of(@entity, @repository.identifier_name)
        key = :"#{@options[:inverse_of]}_id"

        # all the further queries will be scoped by the "foreign_key"
        @repository.local_conditions[key] = id

        # use order_by from options as the default one for further queries
        @repository.local_conditions[:order_by] = @options[:order_by] unless @options[:order_by].blank?

        # all the further calls (method_missing) will be delegated to @repository
        @repository
      end

    end

  end
end
