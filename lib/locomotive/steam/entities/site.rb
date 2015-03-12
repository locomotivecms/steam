module Locomotive::Steam

  class Site

    include Locomotive::Steam::Models::Entity

    def initialize(attributes = {})
      super({
        prefix_default_locale: false
      }.merge(attributes))
    end

    def handle
      self[:handle] || self[:subdomain]
    end

    def default_locale
      locales.try(:first) || :en
    end

    def locales
      self[:locales].map(&:to_sym)
    end

    def timezone_name
      self[:timezone] || self[:timezone_name] || 'UTC'
    end

    def timezone
      @timezone ||= ActiveSupport::TimeZone.new(timezone_name)
    end

    def to_liquid
      Locomotive::Steam::Liquid::Drops::Site.new(self)
    end

  end

end
