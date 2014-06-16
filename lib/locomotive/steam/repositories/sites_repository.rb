module Locomotive
  module Steam
    module Repositories
      class SitesRepository
        include Repository

        def find_by_host(host)
          # TODO multilocales
          query(:en) do
            where('domains.in' => host)
          end.first
        end
      end
    end
  end
end
