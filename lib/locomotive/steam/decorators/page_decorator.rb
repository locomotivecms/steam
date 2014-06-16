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
          binding.pry
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
      end
    end
  end
end
