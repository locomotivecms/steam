module Locomotive::Steam
  module Middlewares

    # Retrieve a page from the path and the locale previously
    # fetched from the request.
    #
    class Page < ThreadSafe

      include Helpers

      def _call
        if page = fetch_page
          log "Found page \"#{page.title}\" [#{page.fullpath}]"
        end

        env['steam.page'] = page
      end

      protected

      def fetch_page
        if (pages = services.page_finder.find(path)).size > 1
          titles = pages.map { |p| p.attributes[:title][repository.current_locale] }
          self.log "Found multiple pages: #{titles.join(', ')}"
        end

        if page = pages.first
          Locomotive::Steam::Decorators::I18nDecorator.new(page, page.localized_attributes, locale, default_locale)
        else
          nil
        end

        # if page = services.page_finder.find(path)
        #   puts page.inspect
        #   Locomotive::Steam::Decorators::I18nDecorator.new(page, page.localized_attributes, locale, site.default_locale)
        # else
        #   nil
        # end

        # decorated(locale) do
        #   Locomotive::Models[:pages].current_locale = locale
        #   Locomotive::Models[:pages].matching_paths(path_combinations(path)).tap do |pages|
        #     if pages.size > 1
        #       self.log "Found multiple pages: #{pages.all.collect(&:title).join(', ')}"
        #     end
        #   end.first
        # end
      end

      # def repository
      #   services.repositories.page
      # end

      # def decorated(locale)
      #   entity = yield
      #   unless entity.nil?
      #     # Locomotive::Steam::Decorators::PageDecorator.new(
      #     #   Locomotive::Decorators::I18nDecorator.new(entity, locale))
      #   end
      # end

    end

  end
end
