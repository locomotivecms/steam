module Locomotive::Steam
  module Middlewares

    module Helpers

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

      def liquid_assigns
        @liquid_assigns ||= env.fetch('steam.liquid_assigns')
      end

      def locales
        site.locales
      end

      def default_locale
        site.default_locale
      end

      def live_editing?
        !!env['steam.live_editing']
      end

      def mounted_on
        env['steam.mounted_on']
      end

      # if this is a JSON request with a JSON body, try to parse it
      # if we are unable to parse it, fallback to the original params
      def params
        return @params if @params.present?

        if json? && (request.post? || request.put?)
          @params = JSON.parse(request.body.read) rescue nil
        end

        @params = (@params || request.params).with_indifferent_access
      end

      #= Useful getters =

      def html?
        ['text/html', 'application/x-www-form-urlencoded', 'multipart/form-data'].include?(self.request.media_type) &&
        !self.request.xhr? &&
        !self.json?
      end

      def json?
        self.request.content_type == 'application/json' || File.extname(self.request.path) == '.json'
      end

      #= Helper methods

      def render_response(content, code = 200, type = nil)
        @next_response = [code, { 'Content-Type' => type || 'text/html' }, [content]]
      end

      def redirect_to(location, type = 301)
        _location = mounted_on && !location.starts_with?(mounted_on) && (location =~ Locomotive::Steam::IsHTTP).nil? ? "#{mounted_on}#{location}" : location

        self.log "Redirected to #{_location}".blue

        @next_response = [type, { 'Content-Type' => 'text/html', 'Location' => _location }, []]
      end

      def modify_path(path = nil, &block)
        path ||= env['steam.path']

        segments = path.split('/')
        yield(segments)
        path = segments.join('/')

        path = '/' if path.blank?
        path += "?#{request.query_string}" unless request.query_string.empty?
        path
      end

      # make sure the location passed in parameter doesn't
      # include the "mounted_on" parameter.
      # If so, returns the location without the "mounted_on" string.
      def make_local_path(location)
        return location if mounted_on.blank?
        location.gsub(Regexp.new('^' + mounted_on), '')
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

      def log(msg, offset = 2)
        Locomotive::Common::Logger.info (' ' * offset) + msg
      end

    end

  end
end
