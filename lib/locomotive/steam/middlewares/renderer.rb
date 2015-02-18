module Locomotive::Steam
  module Middlewares

    class Renderer < ThreadSafe

      include Helpers

      def _call
        if page
          render_page
        else
          render_missing_404
        end
      end

      private

      def render_page
        if page.redirect_url
          redirect_to(page.redirect_url, page.redirect_type)
        else
          content = parse_and_render_liquid
          render_response(content, page.not_found? ? 404: 200)
        end
      end

      def render_missing_404
        log "[Warning] Your 404 page is missing. Please create it.".red
        render_response('Missing 404 page', 404)
      end

      def parse_and_render_liquid
        document = services.liquid_parser.parse(page)
        document.render(liquid_context)
      end

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
          logger:         Locomotive::Common::Logger
        }
      end

      def liquid_assigns
        _default_liquid_assigns.merge(
          _locale_liquid_assigns.merge(
            _request_liquid_assigns.merge(
              _steam_liquid_assigns)))
      end

      def _default_liquid_assigns
        {
          'current_page'      => params[:page],
          'params'            => params.stringify_keys,
          'now'               => Time.zone.now,
          'today'             => Date.today,
          'mode'              => Locomotive::Steam.configuration.mode,
          'wagon'             => Locomotive::Steam.configuration.mode == :test
        }
      end

      def _steam_liquid_assigns
        {
          'site'          => site.to_liquid,
          'page'          => page.to_liquid,
          'models'        => Locomotive::Steam::Liquid::Drops::ContentTypes.new,
          'contents'      => Locomotive::Steam::Liquid::Drops::ContentTypes.new,
          'current_user'  => {},
          'session'       => Locomotive::Steam::Liquid::Drops::SessionProxy.new,
        }.merge(env['steam.liquid_assigns'])
      end

      def _locale_liquid_assigns
        {
          'locale'         => locale,
          'default_locale' => site.default_locale.to_s,
          'locales'        => site.locales.map(&:to_s)
        }
      end

      def _request_liquid_assigns
        {
          'path'        => request.path,
          'fullpath'    => request.fullpath,
          'url'         => request.url,
          'ip_address'  => request.ip,
          'post?'       => request.post?,
          'host'        => request.host_with_port
        }
      end

    end

  end
end
