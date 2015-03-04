module Locomotive::Steam
  module Models

    class BelongsToAssociation < ReferencedAssociation

      def __load__
        name      = @options[:association_name]
        target_id = @entity[:"#{name}_id"]
        target    = @repository.find(target_id)

        # replace the proxy class by the real target entity
        @entity[name] = target
      end

    end

  end
end
