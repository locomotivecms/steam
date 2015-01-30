module Locomotive
  module Steam
    module Repositories

      class Site

        def find_by_host(host)
          raise 'TODO'
          # TODO multilocales
          # query(:en) do
          #   where('domains.in' => host)
          # end.first
        end

      end

    end
  end
end
