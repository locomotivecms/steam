module Locomotive::Steam
  module Models

    # Note: represents an embedded collection
    class HasManyAssociation < ReferencedAssociation

      # TODO: use order_by from options (if specified, "position_in_<@name>" by default
      def __load__
        # Note: in adapters like the FileSystem one, we use slugs
        # to reference other entities in associations.
        id  = @repository.i18n_value_of(@entity, @repository.identifier_name)
        key = :"#{@options[:inverse_of]}_id"

        # all the further queries will be scoped by the "foreign_key"
        @repository.local_conditions[key] = id

        # all the further methods will be delegated to @repository
        @repository
      end

    end

  end
end
