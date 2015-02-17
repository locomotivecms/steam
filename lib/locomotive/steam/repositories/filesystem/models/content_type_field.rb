module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class ContentTypeField < Base

            def initialize(attributes)
              super({
                type:       :string,
                localized:  false,
                required:   false,
                unique:     false
              }.merge(attributes))
            end

            def class_name
              self[:class_name] || self[:target]
            end

            def required?; self[:required]; end
            def localized?; self[:localized]; end

          end

        end
      end
    end
  end
end
