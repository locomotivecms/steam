module Locomotive
  module Steam
    module Services

      class SiteFinder < Struct.new(:repository, :request, :options)

        def find
          repository.by_host(request.host, options)
        end

      end

    end
  end
end
