module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class Snippet < Base

            set_localized_attributes [:template, :template_path]

            def initialize(attributes)
              super({ template: {} }.merge(attributes))
            end

          end

        end
      end
    end
  end
end
