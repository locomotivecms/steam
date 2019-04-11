module Locomotive::Steam
  module Models

    class BelongsToAssociation < ReferencedAssociation

      def __load__
        target_id = @entity[__target_key__]
        target    = @repository.find(target_id)

        # replace the proxy class by the real target entity
        @entity[__name__] = target
      end

      def __serialize__(attributes)
        attributes[__target_key__] = attributes[__name__].try(:_id)

        attributes.delete(__name__)
      end

      def __target_key__
        :"#{__name__}_id"
      end

      def __attach__(entity)
        # setting a default nil value for the target key
        entity[__target_key__] ||= nil
        super
      end

    end

  end
end
