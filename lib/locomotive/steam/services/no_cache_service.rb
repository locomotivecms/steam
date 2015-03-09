module Locomotive
  module Steam

    class NoCacheService

      def fetch(key, options = {}, &block)
        @last_response = block.call
      end

      def read(key)
        nil
      end

    end

  end
end
