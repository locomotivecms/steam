module Locomotive
  module Steam
    module Repositories
      class PagesRepository
        include Repository
        attr_accessor :current_locale

        def [](path)
          query(current_locale) do
            where('fullpath.eq' => path)
          end.first
        end

        def matching_paths(paths)
          query(current_locale) do
            where('fullpath.in' => paths)
            order_by('position ASC')
          end
        end
      end
    end
  end
end
