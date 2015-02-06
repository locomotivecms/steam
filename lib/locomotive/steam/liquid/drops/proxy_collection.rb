module Locomotive
  module Steam
    module Liquid
      module Drops

        class ProxyCollection < ::Liquid::Drop

          delegate :first, :last, :each, :each_with_index, :empty?, :any?, to: :@collection

          def initialize(collection)
            @collection = collection
          end

          def count
            @count ||= @collection.count
          end

          def all
            @collection
          end

          alias :size   :count
          alias :length :count

        end

      end
    end
  end
end
