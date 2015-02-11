module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class Snippet < Struct.new(:attributes)

            def initialize(attributes)
              super({ template: {} }.merge(attributes))
            end

            def method_missing(name, *args, &block)
              if attributes.include?(name)
                attributes[name.to_sym] # getter
              else
                super
              end
            end

            def localized_attributes
              self.class.localized_attributes
            end

            def self.localized_attributes
              [:template, :template_path]
            end

          end

        end
      end
    end
  end
end
