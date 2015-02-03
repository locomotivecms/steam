module Locomotive
  module Steam
    module Services

      class ParentFinder < Struct.new(:site)

        include Morphine

        register :repository do
          Repositories::Page.new(site)
        end

        def find(page, fullpath)
          return nil if fullpath.blank?

          if fullpath.strip == 'parent'
            repository.parent_of(page)
          else
            repository.by_fullpath(fullpath)
          end
        end

      end

    end
  end
end
