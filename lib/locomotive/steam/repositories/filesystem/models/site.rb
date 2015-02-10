module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class Site < Struct.new(:attributes)

            attr_accessor :root_path

            def method_missing(name, *args, &block)
              if attributes.include?(name)
                attributes[name.to_sym] # getter
              else
                super
              end
            end

            def localized_attributes
              [:seo, :meta_description, :meta_keywords]
            end

            def default_locale
              self.locales.try(:first) || :en
            end

            def locales
              attributes[:locales].map(&:to_sym)
            end

            def to_liquid
              Steam::Liquids::Drops::Site.new(self, localized_attributes)
            end

          end

        end
      end
    end
  end
end
