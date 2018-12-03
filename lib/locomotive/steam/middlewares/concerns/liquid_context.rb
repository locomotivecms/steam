module Locomotive::Steam
  module Middlewares
    module Concerns
      module LiquidContext

        private

        def liquid_context
          ::Liquid::Context.new(liquid_assigns, {}, liquid_registers, true)
        end

        def liquid_registers
          {
            request:        request,
            locale:         locale,
            site:           site,
            page:           page,
            services:       services,
            repositories:   services.repositories,
            logger:         Locomotive::Common::Logger,
            live_editing:   live_editing?,
            params:         params,
            session:        request.session,
            cookies:        request.cookies
          }
        end

        def liquid_assigns
          _default_liquid_assigns.merge(
            _locale_liquid_assigns.merge(
              _request_liquid_assigns.merge(
                _http_actions_liquid_assigns.merge(
                  _steam_liquid_assigns))))
        end

        def _default_liquid_assigns
          {
            'current_page'      => params[:page],
            'params'            => Locomotive::Steam::Liquid::Drops::Params.new(params),
            'now'               => Time.zone.now,
            'today'             => Date.today,
            'mode'              => Locomotive::Steam.configuration.mode,
            'wagon'             => Locomotive::Steam.configuration.mode == :test,
            'live_editing'      => live_editing?
          }
        end

        def _steam_liquid_assigns
          {
            'site'          => site.to_liquid,
            'page'          => page.to_liquid,
            'models'        => Locomotive::Steam::Liquid::Drops::ContentTypes.new,
            'contents'      => Locomotive::Steam::Liquid::Drops::ContentTypes.new,
            'session'       => Locomotive::Steam::Liquid::Drops::SessionProxy.new,
          }.merge(env['steam.liquid_assigns'])
        end

        def _locale_liquid_assigns
          {
            'locale'         => locale.to_s,
            'default_locale' => site.default_locale.to_s,
            'locales'        => site.locales.map(&:to_s)
          }
        end

        def _request_liquid_assigns
          {
            'base_url'    => request.base_url,
            'fullpath'    => request.fullpath,
            'http_method' => request.request_method,
            'ip_address'  => request.ip,
            'mounted_on'  => mounted_on,
            'path'        => request.path,
            'referer'     => request.referer,
            'url'         => request.url,
            'user_agent'  => request.user_agent,
            'host'        => request.host_with_port
          }
        end

        def _http_actions_liquid_assigns
          {
            'head?'    => request.head?,
            'get?'    => request.get?,
            'post?'   => request.post?,
            'put?'    => request.put?,
            'delete?' => request.delete?
          }
        end

      end
    end
  end
end
