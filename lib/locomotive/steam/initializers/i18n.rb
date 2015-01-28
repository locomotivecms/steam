I18n.load_path = Dir[File.join(File.dirname(__FILE__), "/../../../../config/locales/*.yml")]
I18n.enforce_available_locales = false
I18n.backend.reload!
