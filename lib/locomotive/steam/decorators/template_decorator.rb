module Locomotive
  module Steam
    module Decorators

      class TemplateDecorator < I18nDecorator

        def liquid_source
          if attributes.key?(:template_path)
            source = File.open(template_path).read.force_encoding('utf-8')

            if match = source.match(/^((---\s*\n.*?\n?)^(---\s*$\n?))?(?<template>.*)/m)
              match[:template]
            else
              source
            end
          else
            self.source
          end
        end

      end

    end
  end
end
