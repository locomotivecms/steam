module Locomotive::Steam
  module Models

    class Pager

      DEFAULT_PER_PAGE = 10.freeze

      attr_reader :collection, :current_page, :per_page, :total_pages, :total_entries

      def initialize(source, page, per_page)
        @current_page, @per_page = page || 1, per_page || DEFAULT_PER_PAGE

        @total_entries  = source.count
        @total_pages    = (@total_entries.to_f / @per_page).ceil

        index   = (@current_page - 1) * @per_page
        offset  = (index + @per_page - 1) >= @total_entries ? @total_entries : (index + @per_page - 1)

        @collection = paginate(source, index, offset)
      end

      def previous_page
        current_page <= 1 ? nil : current_page - 1
      end

      def next_page
        current_page >= total_pages ? nil : current_page + 1
      end

      def to_liquid
        {
          collection:       collection,
          current_page:     current_page,
          per_page:         per_page,
          previous_page:    previous_page,
          next_page:        next_page,
          total_entries:    total_entries,
          total_pages:      total_pages
        }
      end

      private

      def paginate(source, index, offset)
        limit = offset - index + 1
        limit = 0 if limit < 1
        source.send(:slice, index, limit) || []
      end

    end

  end
end
