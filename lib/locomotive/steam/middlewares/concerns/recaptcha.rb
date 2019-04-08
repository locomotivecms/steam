module Locomotive::Steam
  module Middlewares
    module Concerns
      module Recaptcha

        def recaptcha_content_entry_valid?(slug, response)
          !recaptcha_content_entry_required?(slug) || recaptcha_valid?(response)
        end

        def recaptcha_content_entry_required?(slug)
          type = content_entry.get_type(slug)
          # TODO @did we should remove this try when data will be updated?
          !type.nil? && type.try(:recaptcha_required)
        end

        def recaptcha_valid?(response)
          valid = recaptcha.verify(response)
          liquid_assigns['recaptcha_invalid'] = !valid
          valid
        end

        def recaptcha
          services.recaptcha
        end

        def build_invalid_recaptcha_entry(slug, entry_attributes)
          entry = content_entry.build(slug, entry_attributes)
          entry.errors.add(:recaptcha_invalid, true)
          entry
        end

        def content_entry
          services.content_entry
        end

      end
    end
  end
end
