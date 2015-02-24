module Locomotive::Steam
  module Adapters
    module Concerns

      module Key

        def key(name, operator)
          Locomotive::Steam::Adapters::Memory::Query.key(name, operator)
        end

      end

    end
  end
end
