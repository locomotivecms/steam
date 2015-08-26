module Locomotive
  module Steam
    module Liquid
      module Tags
        module Concerns

          module I18nPage

            def change_page_locale(locale, drop, &block)
              page = drop.send(:_source)

              page.__with_locale__(locale) do
                if page.templatized?
                  page.content_entry.__with_locale__(locale) { yield }
                else
                  yield
                end
              end
            end

          end

        end
      end
    end
  end
end
