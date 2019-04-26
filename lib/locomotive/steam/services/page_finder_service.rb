module Locomotive
  module Steam

    class PageFinderService

      include Locomotive::Steam::Services::Concerns::Decorator

      attr_accessor_initialize :repository

      def find(path)
        decorate do
          repository.by_fullpath(path)
        end
      end

      def match(path)
        decorate do
          repository.matching_fullpath(path_combinations(path))
        end.sort do |page_1, page_2|
          # normal pages have priority over the templatized ones if they're not in the same "folder"
          same_folder?(page_1, page_2) ?
            page_1.position <=> page_2.position :
            (page_2.fullpath.include?(WILDCARD) ? 0 : 1) <=> (page_1.fullpath.include?(WILDCARD) ? 0 : 1)
        end
      end

      def by_handle(handle, with_cache = true)
        decorate do
          with_cache ? page_map[handle] : repository.by_handle(handle)
        end
      end

      def find_by_id(id)
        decorate do
          repository.find(id)
        end
      end

      private

      def decorate(&block)
        super(Decorators::PageDecorator, &block)
      end

      # Instead of hitting the DB each time we want a page from its handle,
      # just get all the handles at once and cache the result. (up to 20% boost)
      #
      def page_map
        @page_map ||= {}

        return @page_map[repository.locale] if @page_map[repository.locale]

        {}.tap do |map|
          repository.only_handle_and_fullpath.each do |page|
            map[page.handle] = page
          end

          @page_map[repository.locale] = map
        end
      end

      def path_combinations(path)
        _path_combinations(path.split('/'))
      end

      def same_folder?(page_1, page_2)
        (path_1 = page_1.fullpath.split('/')).pop
        (path_2 = page_2.fullpath.split('/')).pop

        path_1.join('/') == path_2.join('/')
      end

      def _path_combinations(segments, can_include_template = true)
        return nil if segments.empty?
        segment = segments.shift

        (can_include_template ? [segment, WILDCARD] : [segment]).map do |_segment|
          if (_combinations = _path_combinations(segments.clone, can_include_template && _segment != WILDCARD))
            [*_combinations].map do |_combination|
              File.join(_segment, _combination)
            end
          else
            [_segment]
          end
        end.flatten
      end

    end

  end
end
