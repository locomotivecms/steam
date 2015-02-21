module Locomotive
  module Steam
    module Services

      class SiteFinder < Struct.new(:repository, :request)

        def find
          # TODO: full uri instead?
          repository.by_host(request.host)
        end

      end

    end
  end
end
