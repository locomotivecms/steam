module Locomotive
  module Steam
    module Liquid
      module Drops
        class Page < Base
          extend Forwardable

          def_delegators :@_source, :title, :slug, :fullpath, :parent, :depth, :seo_title, :redirect_url, :meta_description, :meta_keywords,
                   :templatized?, :published?, :redirect?, :listed?, :handle

          def children
            _children = @_source.children || []
            _children = _children.sort { |a, b| a.position.to_i <=> b.position.to_i }
            @children ||= liquify(*_children)
          end

          def content_type
            ProxyCollection.new(@_source.content_type) if @_source.content_type
          end

          def breadcrumbs
            # TODO
            ''
          end
        end
      end
    end
  end
end
