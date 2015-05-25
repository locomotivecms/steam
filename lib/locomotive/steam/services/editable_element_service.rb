module Locomotive
  module Steam

    class EditableElementService < Struct.new(:repository, :locale)

      include Locomotive::Steam::Services::Concerns::Decorator

      def find(page, block, slug)
        decorate(Decorators::I18nDecorator) do
          repository.editable_element_for(page, block, slug).tap do |element|
            element.base_url = repository.base_url(page) if element
          end
        end
      end

    end

  end
end
