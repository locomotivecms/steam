module Locomotive
  module Steam

    class SiteFinderService < Struct.new(:repository, :request)

      def find
        repository.by_domain(request.host)
      end

    end

  end
end
