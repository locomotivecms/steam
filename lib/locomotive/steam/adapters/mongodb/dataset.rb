module Locomotive::Steam
  module Adapters
    module MongoDB

      class Dataset < SimpleDelegator

        def initialize(records = [], &block)
          @records = block_given? ? yield : records
          super(@records)
        end

        def all
          @records
        end

      end

    end
  end
end
