module Locomotive::Steam::Middlewares

  class ThreadSafe

    attr_accessor_initialize :app
    attr_accessor :env

    def call(env)
      threadsafed = dup
      threadsafed.env = env

      # time = Benchmark.realtime do
      threadsafed._call # thread-safe purpose
      # end

      # puts "[Benchmark][#{self.class.name}] Time elapsed #{time*1000} milliseconds"

      threadsafed.next
    end

    def next
      # avoid to be called twice
      @next_response || (@next_response = app.call(env))
    end

    #= Shortcuts =

    def services
      @services ||= env.fetch('steam.services')
    end

    def repositories
      @repositories ||= services.repositories
    end

    def request
      @request ||= env.fetch('steam.request')
    end

    def site
      @site ||= env.fetch('steam.site')
    end

    def page
      @page ||= env.fetch('steam.page')
    end

    def path
      @path ||= env.fetch('steam.path')
    end

    def locale
      @locale ||= env.fetch('steam.locale')
    end

    def locales
      site.locales
    end

    def default_locale
      site.default_locale
    end

    def params
      @params ||= self.request.params.with_indifferent_access
    end

    def session
      env['rack.session']
    end

    def liquid_assigns
      @liquid_assigns ||= env.fetch('steam.liquid_assigns')
    end

    def live_editing?
      !!env['steam.live_editing']
    end

    def decorate_entry(entry)
      return nil if entry.nil?
      Locomotive::Steam::Decorators::I18nDecorator.new(entry, locale, default_locale)
    end

    def default_liquid_context
      ::Liquid::Context.new({ 'site' => site.to_liquid }, {}, {
        request:        request,
        locale:         locale,
        site:           site,
        services:       services,
        repositories:   services.repositories
      }, true)
    end

  end

end
