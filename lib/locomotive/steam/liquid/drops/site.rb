module Locomotive
  module Steam
    module Liquid
      module Drops
        class Site < I18nBase

          delegate :name, :handle, :domains, :seo_title, :meta_keywords,
            :meta_description, :asset_host, :sections_content, to: :@_source

          def index
            @index ||= repository.root.to_liquid
          end

          def pages
            liquify(*self.scoped_pages)
          end

          def metafields
            @metafields ||= Metafields.new(@_source)
          end

          protected

          def repository
            @context.registers[:services].repositories.page
          end

          def scoped_pages
            conditions = @context['with_scope'] || {}
            conditions['slug.ne']   = '404'
            conditions[:published]  = true
            repository.all(conditions)
          end

        end
      end
    end
  end
end
