module Locomotive
  module Steam
    module Decorators
      class PageDecorator < SimpleDelegator

        # Return the fullpath dasherized and with the "*" character
        # for the slug of templatized page.
        #
        # @return [ hash ] The safe full paths
        #

        def safe_fullpath
          if index_or_404?
            slug[current_locale]
          else
            base  = parent.safe_fullpath
            _slug = if templatized? && !templatized_from_parent
              '*'
            else
              slug[current_locale]
            end
            (base == 'index' ? _slug : File.join(base, _slug)).dasherize
          end
        end

        def parent
          Locomotive::Steam::Decorators::PageDecorator.new(
            Locomotive::Decorators::I18nDecorator.new(
              __getobj__.parent, current_locale
            )
          )
        end

        # Return the Liquid template based on the raw_template property
        # of the page. If the template is HAML or SLIM, then a pre-rendering to Liquid is done.
        #
        # @return [ String ] The liquid template or nil if not template has been provided
        #
        def source(locale)
          @source ||= self.template[locale].source
        end

        def to_liquid
          ::Locomotive::Steam::Liquid::Drops::Page.new(self)
        end

      end
    end
  end
end
