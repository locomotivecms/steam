module Locomotive::Steam
  module Middlewares

    class Renderer

      def call(env)
        response = nil

        # time = Benchmark.realtime do
          # puts "[Rendered] TODO"
          # self.set_accessors(env)
          response = [200, { 'Content-Type' => 'text/html' }, ['TODO']]
        # end

        # puts "[Benchmark][Renderer] Time elapsed #{time*1000} milliseconds"
        response

        # if page
        #   if page.redirect?
        #     redirect_to(page.redirect_url, page.redirect_type)
        #   else
        #     type = page.response_type || 'text/html'
        #     html = render_page

        #     log 'Rendered liquid page template'

        #     [200, { 'Content-Type' => type }, [html]]
        #   end
        # else
        #   [404, { 'Content-Type' => 'text/html' }, [render_404]]
        # end
      end

      def self.call(env)
        raise 'TODO'
      end

      protected

      def render_page
        context = self.locomotive_context
        # begin
        #   binding.pry
          render(page, context)
        # rescue Exception => e

        #   raise RendererException.new(e, self.page.title, self.page.template, context)
        # end
      end

      def render(page, context)
        parse(page, context).render(context)
      end

      protected

      def parse(page, context)

        options =  {
          page:           page,
          mapper: context.registers[:mapper],
          error_mode:     :strict,
          count_lines:    true
        }

        begin
          ::Liquid::Template.parse(page.source(I18n.locale), options)
        rescue ::Liquid::SyntaxError
          # do it again on the raw source instead so that the error line matches
          # the source file.
          ::Liquid::Template.parse(self.template.raw_source, options)
        end
      end


      def render_404
        if self.page = Locomotive::Models[:pages]['404']
          self.render_page
        else
          'Page not found'
        end
      end

      # Build the Liquid context used to render the Locomotive page. It
      # stores both assigns and registers.
      #
      # @param [ Hash ] other_assigns Assigns coming for instance from the controler (optional)
      #
      # @return [ Object ] A new instance of the Liquid::Context class.
      #
      def locomotive_context(other_assigns = {})
        assigns = self.locomotive_default_assigns

        # assigns from other middlewares
        assigns.merge!(self.liquid_assigns)

        assigns.merge!(other_assigns)

        # templatized page
        if self.page && self.content_entry
          ['content_entry', 'entry', self.page.content_type.slug.singularize].each do |key|
            assigns[key] = self.content_entry
          end
        end

        # Tip: switch from false to true to enable the re-thrown exception flag
        ::Liquid::Context.new({}, assigns, self.locomotive_default_registers, true)
      end

      # Return the default Liquid assigns used inside the Locomotive Liquid context
      #
      # @return [ Hash ] The default liquid assigns object
      #
      def locomotive_default_assigns
        {
          'site'              => self.site.to_liquid,
          'page'              => self.page,
          'models'            => Locomotive::Steam::Liquid::Drops::ContentTypes.new,
          'contents'          => Locomotive::Steam::Liquid::Drops::ContentTypes.new,
          'current_page'      => self.params[:page],
          'params'            => self.params.stringify_keys,
          'path'              => self.request.path,
          'fullpath'          => self.request.fullpath,
          'url'               => self.request.url,
          'ip_address'        => self.request.ip,
          'post?'             => self.request.post?,
          'host'              => self.request.host_with_port,
          'now'               => Time.zone.now,
          'today'             => Date.today,
          'locale'            => I18n.locale.to_s,
          'default_locale'    => self.site.default_locale.to_s,
          'locales'           => self.site.locales.map(&:to_s),
          'current_user'      => {},
          'session'           => Locomotive::Steam::Liquid::Drops::SessionProxy.new,
          'steam'             => true,
          'editing'           => false
        }
      end

      # Return the default Liquid registers used inside the Locomotive Liquid context
      #
      # @return [ Hash ] The default liquid registers object
      #
      def locomotive_default_registers
        {
          request:        self.request,
          site:           self.site,
          page:           self.page,
          services:       self.services,
          inline_editor:  false,
          logger:         Locomotive::Common::Logger
        }
      end

    end

  end
end
