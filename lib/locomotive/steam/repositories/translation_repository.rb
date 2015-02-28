module Locomotive
  module Steam

    class TranslationRepository

      include Models::Repository

      # Entity mapping
      mapping :translations, entity: Translation

      def by_key(key)
        query { where(key: key) }.first
      end

    end
  end
end
