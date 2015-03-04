module Locomotive::Steam
  module Models

    class ReferencedAssociation

      attr_reader :repository

      def initialize(repository_klass, scope, adapter, options = {}, &block)
        # build a new instance of the target repository
        @repository = repository_klass.new(adapter)

        # Note: if we change the locale of the parent repository, that won't
        # reflect in that repository
        @repository.scope = scope.dup

        # the block will executed when a method of the target will be called
        @block = block_given? ? block : nil

        @options = options
      end

      def __attach__(entity)
        @entity = entity
      end

      def __load__
        # needs implementation
      end

      def method_missing(name, *args, &block)
        @block.call(@repository) if @block

        __load__.try(:send, name, *args, &block)
      end

    end

  end
end
