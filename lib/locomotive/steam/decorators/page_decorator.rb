module Locomotive
  module Steam
    module Decorators
      class PageDecorator < I18nDecorator

        def source
          source = File.open(template_path).read.force_encoding('utf-8')

          if match = source.match(/^((---\s*\n.*?\n?)^(---\s*$\n?))?(?<template>.*)/m)
            match[:template]
          else
            source
          end
        end

      end
    end
  end
end
