module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers

        class Snippet

          include Adapters::Filesystem::Sanitizer

          def apply_to_entity(entity)
            attach_site_to(entity)
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
