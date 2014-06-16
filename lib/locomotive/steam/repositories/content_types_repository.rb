module Locomotive
  module Steam
    module Repositories
      class ContentTypesRepository
        include Repository
        def [](slug)
          query(:en) do
            where('slug.eq' => slug.to_s)
          end.first
        end
      end
    end
  end
end
