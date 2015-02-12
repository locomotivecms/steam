module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class Site < Base

            set_localized_attributes [:seo, :meta_description, :meta_keywords]

            attr_accessor :root_path

            def default_locale
              self.locales.try(:first) || :en
            end

            def locales
              attributes[:locales].map(&:to_sym)
            end

            def to_liquid
              Steam::Liquid::Drops::Site.new(self)
            end

          end

        end
      end
    end
  end
end
