# Morphine is a lightweight dependency injection framework for Ruby. It uses a simple Ruby DSL to ease the pain of wiring your dependencies together.
# We do not use the offical gem but rather the single file from here:
# https://github.com/bkeepers/morphine
#

module Morphine
  def self.included(base)
    base.extend ClassMethods
  end

  def dependencies
    @dependencies ||= {}
  end

  module ClassMethods
    def register(name, &block)
      define_method name do |*args|
        dependencies[name] ||= instance_exec(*args,&block)
      end

      define_method "#{name}=" do |service|
        dependencies[name] = service
      end
    end
  end
end
