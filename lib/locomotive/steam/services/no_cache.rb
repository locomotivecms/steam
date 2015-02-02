module Locomotive
  module Steam
    module Services

      class NoCache

        def fetch(key, options = {}, &block)
          block.call
        end

      end

    end
  end
end
