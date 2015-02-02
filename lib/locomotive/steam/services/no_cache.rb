module Locomotive
  module Steam
    module Services

      class NoCache

        def fetch(key, options = {}, &block)
          @last_response = block.call
        end

        def read(key)
          nil
        end

      end

    end
  end
end
