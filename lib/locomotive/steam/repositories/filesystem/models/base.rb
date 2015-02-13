module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Models

          class Base

            attr_accessor :attributes

            def initialize(attributes)
              @attributes = attributes
            end

            def method_missing(name, *args, &block)
              if attributes.include?(name)
                self[name]
              else
                super
              end
            end

            def []=(name, value)
              attributes[name.to_sym] = value
            end

            def [](name)
              attributes[name.to_sym]
            end

            def self.set_localized_attributes(list)
              singleton = class << self; self; end
              singleton.class_eval do
                define_method(:localized_attributes) { list }
              end

              class_eval do
                define_method(:localized_attributes) { list }
              end
            end

          end

        end
      end
    end
  end
end
