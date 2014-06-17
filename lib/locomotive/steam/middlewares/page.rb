module Locomotive::Steam
  module Middlewares

    # Sanitize the path from the previous middleware in order
    # to make it work for the renderer.
    #
    class Page < Base

      def _call(env)
        super

        set_page!(env)

        app.call(env)
      end

      protected

      def set_page!(env)
        page = fetch_page env['steam.locale']
        if page
          log "Found page \"#{page.title}\" [#{page.fullpath}]"
        end

        env['steam.page'] = page
      end

      def fetch_page locale
        decorated(locale) do
          Locomotive::Models[:pages].current_locale = locale
          Locomotive::Models[:pages].matching_paths(path_combinations(path)).tap do |pages|
            if pages.size > 1
              self.log "Found multiple pages: #{pages.all.collect(&:title).join(', ')}"
            end
          end.first
        end
      end

      def decorated(locale)
        entity = yield
        unless entity.nil?
          Locomotive::Steam::Decorators::PageDecorator.new(
            Locomotive::Decorators::I18nDecorator.new(entity, locale))
        end
      end

      def path_combinations(path)
        self._path_combinations(path.split('/'))
      end

      def _path_combinations(segments, can_include_template = true)
        return nil if segments.empty?

        segment = segments.shift

        (can_include_template ? [segment, '*'] : [segment]).map do |_segment|
          if (_combinations = _path_combinations(segments.clone, can_include_template && _segment != '*'))
            [*_combinations].map do |_combination|
              URI.join(_segment, _combination)
            end
          else
            [_segment]
          end
        end.flatten
      end

    end

  end
end
