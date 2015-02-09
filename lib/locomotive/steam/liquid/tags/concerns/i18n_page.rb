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

            # def build_fullpath(page)
            #   services.url_builder.url_for(page, locale).tap do |fullpath|
            #     if page.templatized?
            #       entry = page.send(:_source).content_entry
            #       fullpath.gsub!('content_type_template', entry._slug)
            #     end
            #   end
            # end

          end

        end
      end
    end
  end
end
