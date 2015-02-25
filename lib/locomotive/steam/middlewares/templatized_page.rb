module Locomotive::Steam
  module Middlewares

    class TemplatizedPage < ThreadSafe

      include Helpers

      def _call
        if page && page.templatized?
          set_content_entry!
        end
      end

      protected

      def set_content_entry!
        # extract the slug of the content entry
        %r(^#{page.fullpath.gsub(Locomotive::Steam::WILDCARD, '([^\/]+)')}$) =~ path

        if entry = fetch_content_entry($1)
          # the entry will be available in the template under different keys
          ['content_entry', 'entry', entry.content_type.slug.singularize].each do |key|
           liquid_assigns[key] = entry
          end

          env['steam.content_entry'] = page.content_entry = entry

          # log it
          log "Found content entry: #{entry._label}"
        else
          redirect_to '/404', 302
        end
      end

      def fetch_content_entry(slug)
        if type = content_type_repository.by_slug(page.content_type)
          decorate(content_entry_repository.by_slug(type, slug))
        else
          nil
        end
      end

      def decorate(entry)
        return nil if entry.nil?
        Locomotive::Steam::Decorators::I18nDecorator.new(entry, nil, default_locale)
      end

      def content_type_repository
        services.repositories.content_type
      end

      def content_entry_repository
        services.repositories.content_entry
      end

    end
  end
end
