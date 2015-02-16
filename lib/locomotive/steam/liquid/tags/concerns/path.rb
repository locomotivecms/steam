module Locomotive
  module Steam
    module Liquid
      module Tags
        module Concerns
          module Path

            Syntax = /(#{::Liquid::VariableSignature}+)(\s*,.+)?/o

            def initialize(tag_name, markup, options)
              if markup =~ Syntax
                @handle, _options = $1, $2

                # FIXME: the with option needs a string with quotes.
                # this is a hack for sites which don't follow the new syntax.
                _options.gsub!(/with: ([\w-]+)/, 'with: "\1"') if _options

                @raw_path_options = parse_options_from_string(_options)
              else
                self.wrong_syntax!
              end

              super
            end

            def render_path(context, &block)
              set_vars_from_context(context)

              # return a drop or model?
              if page = self.retrieve_page_drop_from_handle
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

            def retrieve_page_drop_from_handle
              handle = @context[@handle] || @handle

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
              if page = repository.by_handle(handle)
                page.to_liquid.tap { |d| d.context = @context }
              end
            end

            def _retrieve_templatized_page_drop_from(drop)
              entry = drop.send(:_source)

              if page = repository.template_for(entry, @path_options[:with])
                page.to_liquid.tap { |d| d.context = @context }
              end
            end

            def build_fullpath(page)
              services.url_builder.url_for(page.send(:_source), locale)
            end

            def locale
              @path_options[:locale] || @locale
            end

            def set_vars_from_context(context)
              @context      = context
              @path_options = evaluate_path_options(context)
              @site         = context.registers[:site]
              @locale       = context.registers[:locale]
            end

            def evaluate_path_options(context)
              interpolate_options(@raw_path_options, context)
            end

          end
        end
      end
    end
  end
end
