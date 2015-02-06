module Locomotive
  module Steam
    module Liquid
      module Drops
        class Site < Base

          delegate :name, :domains, :seo_title, :meta_keywords, :meta_description, to: :@_source

          def index
            @index ||= repository.root.to_liquid
          end

          def pages
            @pages ||= liquify(*self.scoped_pages)
          end

          protected

          def repository
            @context.registers[:services].repositories.page
          end

          def scoped_pages
            repository.all(@context['with_scope'])

          end

        end
      end
    end
  end
end
