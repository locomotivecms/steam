module Locomotive
  module Steam

    class SiteFinderService

      attr_accessor_initialize :repository, :request

      def find
        repository.by_domain(request.host) if request
      end

    end

  end
end
