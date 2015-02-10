module Locomotive
  module Steam
    module Liquid
      module Tags

        # Display the links to change the locale of the current page
        #
        # Usage:
        #
        # {% locale_switcher %} => <div id="locale-switcher"><a href="/features" class="current en">Features</a><a href="/fr/fonctionnalites" class="fr">Fonctionnalités</a></div>
        #
        # {% locale_switcher label: locale, sep: ' - ' }
        #
        # options:
        #   - label: iso (de, fr, en, ...etc), locale (Deutsch, Français, English, ...etc), title (page title)
        #   - sep: piece of html code separating 2 locales
        #
        # notes:
        #   - "iso" is the default choice for label
        #   - " | " is the default separating code
        #

        class LocaleSwitcher < Solid::Tag

          include Concerns::I18nPage

          tag_name :locale_switcher

          def display(*values)
            @options = { label: 'iso', sep: ' | ' }.merge(values.first || {})
            %{<div id="locale-switcher">#{build_site_locales}</div>}
          end

          private

          def build_site_locales
            site.locales.map do |locale|
              change_page_locale(locale, page) do
                css   = link_class(locale)
                path  = link_path(locale)

                %(<a href="#{path}" class="#{css}">#{link_label(locale)}</a>)
              end
            end.join(@options[:sep])
          end

          def link_class(locale)
            css = [locale]
            css << 'current' if locale.to_sym == current_locale.to_sym
            css.join(' ')
          end

          def link_path(locale)
            url_builder.url_for(page.send(:_source), locale)
          end

          def link_label(locale)
            case @options[:label]
            when 'locale' then I18n.t("locomotive.locales.#{locale}")
            when 'title' then page_title
            else
              locale
            end
          end

          def page_title
            if page.templatized?
              page.send(:_source).content_entry._label
            else
              page.title
            end
          end

          def site
            @site ||= current_context.registers[:site]
          end

          def page
            @page ||= current_context['page']
          end

          def url_builder
            current_context.registers[:services].url_builder
          end

          def current_locale
            @current_locale ||= current_context.registers[:locale]
          end

        end

      end
    end
  end
end
