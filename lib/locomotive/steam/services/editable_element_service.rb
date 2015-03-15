module Locomotive
  module Steam

    class EditableElementService < Struct.new(:repository, :locale)

      include Locomotive::Steam::Services::Concerns::Decorator

      def find(page, block, slug)
        decorate do
          repository.editable_element_for(page, block, slug)
        end
      end

    end

  end
end
