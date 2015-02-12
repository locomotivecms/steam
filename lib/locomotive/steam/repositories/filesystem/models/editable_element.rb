module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class EditableElement < Struct.new(:block, :slug, :content)
          end

        end
      end
    end
  end
end
