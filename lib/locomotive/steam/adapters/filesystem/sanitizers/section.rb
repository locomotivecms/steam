require 'pry'
module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers

        class Section

          include Adapters::Filesystem::Sanitizer

          def apply_to_entity(entity)
            super
            
            json_formatter = /^---(?<json>(\s*\n.*?\n?))^---/mo

            file_path = entity[:template_path].translations[:en]
            file_content = File.read(file_path)
            json = file_content.match(json_formatter)
            entity.definition = JSON.parse(json[:json])

            use_default_template_if_missing_locale(entity)
          end

          private

          def use_default_template_if_missing_locale(entity)
            # if there a missing template in one of the locales,
            # then use the one from the default locale
            default = entity.template_path[default_locale]
            locales.each do |locale|
              next if locale == default_locale
              entity.template_path[locale] ||= default
            end
          end

        end

      end
    end
  end
end
