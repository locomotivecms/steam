module Locomotive
  module Steam
    module Repositories

      class Page < Struct.new(:site)

        def find_by_handle(handle)
          site.pages.where(handle: handle).first
        end

      end

    end
  end
end
