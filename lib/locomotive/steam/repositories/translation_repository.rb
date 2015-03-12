module Locomotive
  module Steam

    class TranslationRepository

      include Models::Repository

      # Entity mapping
      mapping :translations, entity: Translation

      def by_key(key)
        first { where(key: key) }
      end

    end
  end
end
