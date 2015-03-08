require_relative 'page_finder_service'

module Locomotive
  module Steam

    class ParentFinderService < PageFinderService

      def find(page, fullpath)
        return nil if fullpath.blank?

        decorate do
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
