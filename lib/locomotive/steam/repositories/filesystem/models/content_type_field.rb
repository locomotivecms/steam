module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class ContentTypeField < Base

            def initialize(attributes)
              super({
                type: :string
              }.merge(attributes))
            end

          end

        end
      end
    end
  end
end
