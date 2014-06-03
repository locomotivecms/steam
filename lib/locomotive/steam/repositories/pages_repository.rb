module Locomotive
  module Steam
    module Repositories
      class PagesRepository
        include Repository

        def [](path)
          matching_paths([paths])
        end

        def matching_paths(paths)
          # TODO multilocales
          query(:en) do
            where('fullpath.in' => paths)
            order_by('position ASC')
          end
        end
      end
    end
  end
end
