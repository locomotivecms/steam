module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class Page < Base

            set_localized_attributes [:title, :slug, :permalink, :template, :template_path, :fullpath, :seo, :meta_description, :meta_keywords]

            def initialize(attributes)
              super({
                listed:       true,
                published:    false,
                fullpath:     {},
                content_type: nil,
                position:     100,
                template:     {}
              }.merge(attributes))
            end

            def templatized?
              !!content_type
            end

            def not_found?
              attributes[:fullpath].values.first == '404'
            end

            def to_liquid
              Steam::Liquid::Drops::Page.new(self)
            end

          end

        end
      end
    end
  end
end
