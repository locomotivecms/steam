module Locomotive::Steam
  module Middlewares

    class TemplatizedPage < ThreadSafe

      include Concerns::Helpers

      def _call
        if page && page.templatized?
          set_content_entry!
        end
      end

      protected

      def set_content_entry!
        # extract the slug of the content entry
        %r(^#{page.fullpath.gsub(Locomotive::Steam::WILDCARD, '([^\/]+)')}$) =~ path

        if entry = fetch_content_entry($1 || params['id'])
          # the entry will be available in the template under different keys
          ['content_entry', 'entry', entry.content_type.slug.singularize].each do |key|
           liquid_assigns[key] = entry
          end

          env['steam.content_entry'] = page.content_entry = entry

          # log it
          debug_log "Found content entry: #{entry._label}"
        else
          log "C"*25
          url = services.url_builder.url_for(page_not_found, locale)
          redirect_to url, 404
        end
      end

      def fetch_content_entry(slug)
        if type = content_type_repository.find(page.content_type_id)
          # don't accept a non localized entry in a locale other than the default one
          return nil if type.localized_names.count == 0 && locale.to_s != default_locale.to_s

          decorate_entry(content_entry_repository.with(type).by_slug(slug))
        else
          nil
        end
      end

      def content_type_repository
        services.repositories.content_type
      end

      def content_entry_repository
        services.repositories.content_entry
      end

      def page_not_found
        services.page_finder.find('404')
      end

    end
  end
end
