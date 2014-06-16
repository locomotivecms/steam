module Locomotive
  module Steam
    module Entities
      class Site
        class NullObject
          def method_missing *args
            nil
          end
        end
        include Locomotive::Entity

        attributes :name, :locales, :subdomain, :domains, :seo_title,
                   :meta_keywords, :meta_description, :robots_txt, :timezone
        ## methods ##

        def default_locale
          locales.first
        end

        def to_s
          self.name
        end

        def to_liquid
          ::Locomotive::Steam::Liquid::Drops::Site.new(self)
        end
      end
    end
  end
end
