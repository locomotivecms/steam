module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class ContentTypeField < Base

            def initialize(attributes)
              super({
                type:       :string,
                localized:  false
              }.merge(attributes))
            end

            def class_name
              self[:class_name] || self[:target]
            end

          end

        end
      end
    end
  end
end
