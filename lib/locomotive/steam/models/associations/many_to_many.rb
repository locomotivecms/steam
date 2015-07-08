module Locomotive::Steam
  module Models

    class ManyToManyAssociation < ReferencedAssociation

      def __load__
        key = @repository.k(:_id, :in)

        @repository.local_conditions[key] = @entity[__target_key__]

        # use order_by from options as the default one for further queries
        @repository.local_conditions[:order_by] = @options[:order_by] unless @options[:order_by].blank?

        # all the further calls (method_missing) will be delegated to @repository
        @repository
      end

      def __serialize__(attributes)
        attributes[__target_key__] = attributes[__name__].try(:map, &:_id)

        attributes.delete(__name__)
      end

      def __target_key__
        :"#{__name__.to_s.singularize}_ids"
      end


    end

  end
end
