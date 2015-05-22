require_relative 'page_finder_service'

module Locomotive
  module Steam

    class ParentFinderService < PageFinderService

      def find(page, fullpath)
        return nil if fullpath.blank?

        if fullpath.strip == 'parent'
          decorate { repository.parent_of(page) }
        else
          super(fullpath)
        end
      end

    end

  end
end
