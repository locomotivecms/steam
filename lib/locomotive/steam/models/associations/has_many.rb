module Locomotive::Steam
  module Models

    class HasManyAssociation < ReferencedAssociation

      def __load__
        key = :"#{@options[:inverse_of]}_id"

        # all the further queries will be scoped by the "foreign_key"
        @repository.local_conditions[key] = @entity._id

        # use order_by from options as the default one for further queries
        @repository.local_conditions[:order_by] = @options[:order_by] unless @options[:order_by].blank?

        # all the further calls (method_missing) will be delegated to @repository
        @repository
      end

    end

  end
end
