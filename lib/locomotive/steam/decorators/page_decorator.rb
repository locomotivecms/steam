require_relative 'template_decorator'

module Locomotive
  module Steam
    module Decorators

      class PageDecorator < TemplateDecorator

        def redirect?
          redirect.nil? ? redirect_url.present? : redirect
        end

      end

    end
  end
end



