module Locomotive::Steam

  class Site

    include Locomotive::Steam::Models::Entity

    def initialize(attributes = {})
      super({
        cache_enabled:            false,
        cache_control:            nil,
        cache_vary:               nil,
        bypass_browser_locale:    false,
        prefix_default_locale:    false,
        updated_at:               nil,
        content_version:          nil,
        template_version:         nil,
        domains:                  [],
        redirect_to_first_domain: false,
        redirect_to_https:        false,
        url_redirections:         [],
        private_access:           false,
        password:                 nil,
        metafields_schema:        {},
        metafields:               nil,
        sections:                 nil,
        sections_content:         nil,
        asset_host:               nil,
        allow_dots_in_slugs:      false,
        routes:                   []
      }.merge(attributes))
    end

    def handle
      self[:handle] || self[:subdomain]
    end

    def default_locale
      locales.first || :en
    end

    def locales
      (self[:locales] || [:en]).map(&:to_sym)
    end

    def timezone_name
      self[:timezone] || self[:timezone_name] || 'UTC'
    end

    def timezone
      @timezone ||= ActiveSupport::TimeZone.new(timezone_name)
    end

    def last_modified_at
      [self.content_version, self.template_version].compact.sort.last || self.updated_at
    end

    def to_liquid
      Locomotive::Steam::Liquid::Drops::Site.new(self)
    end

  end

end
