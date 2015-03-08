module Locomotive
  module Steam

    class SiteFinder < Struct.new(:repository, :request)

      def find
        # TODO: full uri instead?
        repository.by_host(request.host)
      end

    end

  end
end
