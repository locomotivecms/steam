module Locomotive
  module Steam
    module Liquid
      module Drops
        class Site < Base
          include Scopeable
          extend Forwardable

          def_delegators :@_source, :name, :seo_title, :meta_description, :meta_keywords

          def index
            @index ||= self.mounting_point.pages['index']
          end

          def pages
            liquify(*apply_scope(self.mounting_point.pages.values))
          end

          def domains
            @_source.domains
          end

        end
      end
    end
  end
end
