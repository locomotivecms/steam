module Locomotive
  module Steam
    module Repositories

      class Page < Struct.new(:site)

        def by_handle(handle)
          site.pages.where(handle: handle).first
        end

        def parent_of(page)
          page.parent
        end

        def by_fullpath(path)
          site.pages.where(fullpath: path).first
        end

      end

    end
  end
end
