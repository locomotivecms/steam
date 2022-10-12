module Locomotive
  module Steam
    module Liquid
      module Tags
        module Concerns
          module Path

            Syntax = /(#{::Liquid::QuotedFragment}+)(\s*,.+)?/o

            attr_reader :handle

            def initialize(tag_name, markup, options)
              super

              if markup =~ Syntax
                @handle, _attributes = $1, $2

                parse_attributes(_attributes)
              else
                self.wrong_syntax!
              end
            end

            def render_path(context, &block)
              evaluate_attributes(context, lax: true)

              set_vars_from_context(context)

              handle = @context[@handle] || @handle

              # is external url?
              if handle =~ Locomotive::Steam::IsHTTP
                handle
              elsif page = self.retrieve_page_drop_from_handle(handle) # return a drop or model?
                # make sure we've got the page/content entry (if templatized)
                # in the right locale
                change_page_locale(locale, page) do
                  path = build_fullpath(page)

                  block_given? ? block.call(page, path) : path
                end
              else
                '' # no page found
              end
            end

            protected

            def services
              @context.registers[:services]
            end

            def repository
              services.repositories.page
            end

            def retrieve_page_drop_from_handle(handle)
              case handle
              when String
                _retrieve_page_drop_from(handle)
              when Locomotive::Steam::Liquid::Drops::ContentEntry
                _retrieve_templatized_page_drop_from(handle)
              when Locomotive::Steam::Liquid::Drops::Page
                handle
              else
                nil
              end
            end

            def _retrieve_page_drop_from(handle)
              if page = services.page_finder.by_handle(handle)
                page.to_liquid.tap { |d| d.context = @context }
              end
            end

            def _retrieve_templatized_page_drop_from(drop)
              entry = drop.send(:_source)

              if page = repository.template_for(entry, template_slug)
                page.to_liquid.tap { |d| d.context = @context }
              end
            end

            def build_fullpath(page)
              services.url_builder.url_for(page.send(:_source), locale)
            end

            def locale
              attributes[:locale] || @locale
            end

            def template_slug
              attributes[:with]
            end

            def set_vars_from_context(context)
              @context      = context
              @site         = context.registers[:site]
              @locale       = context.registers[:locale]
            end

          end
        end
      end
    end
  end
end