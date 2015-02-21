module Locomotive
  module Steam
    module Entities

      class Site

        include Steam::Entity

        def initialize(attributes = {})
          super({
            timezone: 'UTC',
            prefix_default_locale: false
          }.merge(attributes))
        end

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
