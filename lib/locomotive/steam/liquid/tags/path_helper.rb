module Locomotive
  module Steam
    module Liquid
      module Tags
        module PathHelper

          Syntax = /(#{::Liquid::VariableSignature}+)/o

          def initialize(tag_name, markup, options)
            if markup =~ Syntax
              @handle       = $1
              @path_options = {}
              markup.scan(::Liquid::TagAttributes) do |key, value|
                @path_options[key] = value
              end
            else
              self.wrong_syntax!
            end

            super
          end

          def render_path(context, &block)
            site  = context.registers[:site]

            if page = self.retrieve_page_from_handle(site, context)
              path = self.public_page_fullpath(site, page)

              if block_given?
                block.call page, path
              else
                path
              end
            else
              '' # no page found
            end
          end

          protected

          def retrieve_page_from_handle(site, context)
            handle = context[@handle] || @handle

            # Note/TODO: we manipulate here only Liquid drops!
            case handle
            when Locomotive::Page                         then handle
            when Locomotive::Liquid::Drops::Page          then handle.instance_variable_get(:@_source)
            when String                                   then fetch_page(site, handle)
            when Locomotive::ContentEntry                 then fetch_page(site, handle, true)
            when Locomotive::Liquid::Drops::ContentEntry  then fetch_page(site, handle.instance_variable_get(:@_source), true)
            else
              nil
            end
          end

          def fetch_page(site, handle, templatized = false)
            # TODO: responsability of the page repository, no need of I18n
            # since the source is a I18nDecorated Page model :-)
            ::Mongoid::Fields::I18n.with_locale(self.locale) do
              if templatized
                criteria = site.pages.where(target_klass_name: handle.class.to_s, templatized: true)
                criteria = criteria.where(handle: @path_options['with']) if @path_options['with']
                criteria.first.tap do |page|
                  page.content_entry = handle if page
                end
              else
                site.pages.where(handle: handle).first
              end
            end
          end

          def public_page_fullpath(site, page)
            # TODO: responsability of the url_builder service

            fullpath = site.localized_page_fullpath(page, self.locale)

            if page.templatized?
              fullpath.gsub!('content_type_template', page.content_entry._slug)
            end

            File.join('/', fullpath)
          end

          # def locale
          #   @path_options['locale'] || I18n.locale
          # end

        end
      end
    end
  end
end
