module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class Page < Struct.new(:attributes)

            def initialize(attributes)
              super({
                listed:       true,
                published:    false,
                fullpath:     {},
                content_type: nil,
                position:     100
              }.merge(attributes))
            end

            def method_missing(name, *args, &block)
              if attributes.include?(name)
                attributes[name.to_sym] # getter
              else
                super
              end
            end

            def templatized?
              !!content_type
            end

            def localized_attributes
              self.class.localized_attributes
            end

            def self.localized_attributes
              [:title, :slug, :permalink, :template_path, :fullpath, :seo, :meta_description, :meta_keywords]
            end

            def to_liquid
              Steam::Liquids::Drops::Page.new(self, localized_attributes)
            end

          end

        end
      end
    end
  end
end
