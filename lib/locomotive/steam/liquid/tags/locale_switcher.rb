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
        class LocaleSwitcher < ::Liquid::Tag

          include Concerns::SimpleAttributesParser
          include Concerns::I18nPage

          attr_reader :attributes, :site, :page, :current_locale, :url_builder

          def initialize(tag_name, markup, options)
            super

            parse_attributes(markup, label: 'iso', sep: ' | ')
          end

          def render(context)
            evaluate_attributes(context)

            set_vars_from_context(context)

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
            end.join(attributes[:sep])
          end

          def link_class(locale)
            css = [locale]
            css << 'current' if locale.to_sym == current_locale
            css.join(' ')
          end

          def link_path(locale)
            url_builder.url_for(page.send(:_source), locale)
          end

          def link_label(locale)
            case attributes[:label]
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

          def set_vars_from_context(context)
            @context        = context
            @site           = context.registers[:site]
            @page           = context['page']
            @current_locale = context.registers[:locale].to_sym
            @url_builder    = context.registers[:services].url_builder
          end

        end

        ::Liquid::Template.register_tag('locale_switcher'.freeze, LocaleSwitcher)

      end
    end
  end
end
