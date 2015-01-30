module Locomotive
  module Steam
    module Services

      class SiteFinder < Struct.new(:repository, :request, :options)

        def find
          repository.find_by_host(request.host)
        end

      end

    end
  end
end
